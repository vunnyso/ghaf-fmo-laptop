# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
{
  config,
  lib,
  pkgs,
  ...
}:
{
  msg = {
    enable = true;
    ramMb = 1024;
    cores = 2;
    borderColor = "#000000";
    applications = [ ];
    extraModules = [
      (import ./config.nix { inherit pkgs lib config; })
    ];
  };
}
