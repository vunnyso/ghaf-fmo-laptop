# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  ...
}:
let
  inherit (config.ghaf.networking) hosts;
in
{
  config = {

    # Adjust the MTU for the ethint0 interface
    systemd.network.links."10-ethint0".extraConfig = "MTUBytes=1372";

    # Fix for Ethernet e1000e device
    # TODO seems to be unused?

    services = {
      # Avahi
      # check if ghaf.systemd enabled
      avahi = {
        enable = true;
        nssmdns4 = true;
        reflector = true;
      }; # services.avahi

      # TODO this should be unnecessary, ssh authorized key command
      # fmo-psk-distribution-service-vm = {
      #   enable = true;
      # }; # services.fmo-psk-distribution-service-vm

      dynamic-portforwarding-service = {
        enable = true;
        # TODO what ip is this? from some external if?
        ipaddress = "192.168.100.12";
        ipaddress-path = "/etc/NetworkManager/system-connections/ip-address";
        config-path = "/etc/NetworkManager/system-connections/dpf.config";
        configuration = [
          {
            # Hardcoded docker-vm address
            # dip = "192.168.101.11";
            dip = hosts.docker-vm.ipv4;
            dport = "4222";
            sport = "4222";
            proto = "tcp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "4222";
            sport = "4222";
            proto = "udp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "7222";
            sport = "7222";
            proto = "tcp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "7222";
            sport = "7222";
            proto = "udp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "6422";
            sport = "6422";
            proto = "tcp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "6423";
            sport = "6423";
            proto = "udp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "123";
            sport = "123";
            proto = "udp";
          }
          {
            dip = hosts.docker-vm.ipv4;
            dport = "123";
            sport = "123";
            proto = "tcp";
          }
        ];
      }; # services.portforwarding-service;
    }; # services

    microvm = {
      volumes = [
        {
          image = "/persist/tmp/netvm_internal.img";
          mountPoint = "/var/lib/internal";
          size = 10240;
          autoCreate = true;
          fsType = "ext4";
        }
      ]; # microvm.volumes

      shares = [
        {
          source = "/persist/vms_shares/common";
          mountPoint = "/var/vms_share/common";
          tag = "common_share_netvm";
          proto = "virtiofs";
          socket = "common_share_netvm.sock";
        }
        {
          source = "/persist/vms_shares/netvm";
          mountPoint = "/var/vms_share/host";
          tag = "netvm_share";
          proto = "virtiofs";
          socket = "netvm_share.sock";
        }
        # Using impermanence in ghaf for this
        # {
        #   source = "/var/netvm/netconf";
        #   mountPoint = "/etc/NetworkManager/system-connections";
        #   tag = "netconf";
        #   proto = "virtiofs";
        #   socket = "netconf.sock";
        # }
        {
          source = "/run/certs/nats/clients/netvm";
          mountPoint = "/var/lib/nats/certs";
          tag = "nats_netvm_certs";
          proto = "virtiofs";
          socket = "nats_netvm_certs.sock";
        }
        {
          source = "/run/certs/nats/ca";
          mountPoint = "/var/lib/nats/ca";
          tag = "nats_netvm_ca_certs";
          proto = "virtiofs";
          socket = "nats_netvm_ca_certs.sock";
        }
      ]; # microvm.shares
    }; # microvm

  };
}
