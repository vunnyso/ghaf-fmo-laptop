# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "A Ghaf-based FMO laptop";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/73cf49b8ad837ade2de76f87eb53fc85ed5d4680";
    };

    ghaf = {
      url = "github:tiiuae/ghaf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Random stuff?!? TODO why is this required
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # Other stuff due to overlay in builder
    ghafpkgs = {
      url = "github:tiiuae/ghafpkgs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        crane.follows = "givc/crane";
        devshell.follows = "devshell";
      };
    };
    givc = {
      url = "github:tiiuae/ghaf-givc/62a62c682435a216e324e262f28c7184ab45663e";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        devshell.follows = "devshell";
      };
    };
  };

 outputs = inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    imports = [
      ./devshell.nix
      ./targets/flake-module.nix
      ./modules/flake-module.nix
      ./profile/flake-module.nix
    ];
  };
}
