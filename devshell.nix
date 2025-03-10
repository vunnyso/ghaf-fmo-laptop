# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem =
    { pkgs, config, ... }:
    {
      devshells.default = {
        devshell = {
          name = "Ghaf FMO OS";
          motd = ''
            {14}{bold}❄️ Welcome to devs hell ❄️{reset}
            $(type -p menu &>/dev/null && menu)
          '';
        };
        packages = with pkgs; [
        ];
        commands = [
        ];
      };
    };
}
