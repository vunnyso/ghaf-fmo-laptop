# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  config,
  ...
}:
let
  cfg = config.services.fmo-firewall;

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optionalAttrs
    concatStringsSep
    concatMapStringsSep
    ;

  mkFirewallRules =
    {
      interface,
      dip,
      sport,
      dport,
      proto,
    }:
    ''
      iptables -t nat -A PREROUTING -i ${interface} -p ${proto} --dport ${sport} -j DNAT --to-destination ${dip}:${dport}
      iptables -t nat -A POSTROUTING -o ${interface} -p ${proto} --dport ${sport} -j MASQUERADE
    '';

in
{
  options.services.fmo-firewall = {
    enable = mkEnableOption "fmo-firewall";

    externalNics = mkOption {
      type = types.listOf types.str;
      description = ''
        List of external network interfaces with port forwarding rules.
      '';
    };

    mtu = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        MTU for the external network interfaces.
      '';
    };

    configuration = mkOption {
      type = types.listOf types.attrs;
      description = ''
        List of
          {
            dip = destanation IP address,
            sport = source port,
            dport = destanation port,
            proto = protocol (udp, tcp)
          }
      '';
    };
  };

  config = mkIf cfg.enable {

    networking.firewall = {
      enable = true;
      extraCommands = ''
        ${concatMapStringsSep "\n" (
          rule:
          (concatMapStringsSep "\n" (
            nic:
            mkFirewallRules {
              interface = nic;
              inherit (rule) dip;
              inherit (rule) sport;
              inherit (rule) dport;
              inherit (rule) proto;
            }
          ) cfg.externalNics)
        ) cfg.configuration}
      '';
    };

    # Set MTU
    environment.etc."NetworkManager/dispatcher.d/99-mtu" = optionalAttrs (cfg.mtu != null) {
      text = ''
        #!/bin/sh
        IFACE="$1"
        STATUS="$2"
        case "$STATUS" in
          up)
            for iface in ${concatStringsSep " " cfg.externalNics}; do
              if [[ "$IFACE" == "$iface" ]]; then
                ip link set dev "$IFACE" mtu ${toString cfg.mtu}
              fi
            done
          ;;
        esac
      '';
      mode = "0700";
    };

  };
}
