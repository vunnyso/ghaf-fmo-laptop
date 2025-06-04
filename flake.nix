# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "A Ghaf-based FMO laptop";

  nixConfig = {
    substituters = [
      "https://cache.ssrcdevops.tii.ae"
      "https://ghaf-dev.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-substituters = [
      "https://cache.ssrcdevops.tii.ae"
      "https://ghaf-dev.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "cache.ssrcdevops.tii.ae:oOrzj9iCppf+me5/3sN/BxEkp5SaFkHfKTPPZ97xXQk="
      "ghaf-dev.cachix.org-1:S3M8x3no8LFQPBfHw1jl6nmP8A7cVWKntoMKN3IsEQY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    allow-import-from-derivation = false;
  };

  inputs = {

    #TODO: this needs to be pinned to the version that ghaf is currently pinned to.
    # rather painful. though it can be pinned to official releases this way.
    nixpkgs = {
      url = "github:NixOS/nixpkgs?rev=063f43f2dbdef86376cc29ad646c45c46e93234c";
    };

    ghaf = {
      #url = "flake:mylocalghaf";
      url = "github:tiiuae/ghaf/671aa7dfbca5495cee0dddcefdbbbc7663363b16";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    onboarding-agent = {
      url = "git+ssh://git@github.com/tiiuae/onboarding-agent";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "ghaf/flake-utils";
      };
    };

    ###
    # Flake and repo structuring configurations
    ###
    # Format all the things
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # To ensure that checks are run locally to enforce cleanliness
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-root.url = "github:srid/flake-root";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###
    ### End of Flake and repo structuring configurations
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        ./modules/flake-module.nix
        ./nix/flake-module.nix
        ./overlays/flake-module.nix
        ./targets/flake-module.nix
        ./packages/flake-module.nix
      ];
    };
}
