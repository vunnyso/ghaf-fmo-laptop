# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
#TODO: remove this file once the config builder is exported from ghaf.
{ inputs, ... }:
let
  system = "x86_64-linux";
  mkFmoLaptopConfiguration =
    name: extraModules:
    let
      hostConfig = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          {
            nixpkgs = {
              hostPlatform = { inherit system; };

              config.allowUnfree = true;

              overlays = [
                inputs.ghaf.overlays.default
                inputs.self.overlays.custom-packages
                inputs.self.overlays.own-pkgs-overlay
              ];
            };
          }
        ] ++ extraModules;
      };
    in
    {
      inherit hostConfig;
      inherit name;
      package = hostConfig.config.system.build.diskoImages;
    };
in
mkFmoLaptopConfiguration
