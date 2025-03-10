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
  name = "docker";
  ramMb = 4096;
  cores = 2;
  borderColor = "#000000";
  applications = [ ];
  extraModules = [
    (import ./dockervm.nix { inherit pkgs lib config; })
  ];
}
