# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = [
      pkgs.google-chrome
      pkgs.libaom
    ];
  };
}
