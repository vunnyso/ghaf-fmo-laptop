# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.ghaf.networking) hosts;
in
{
  config = {

    # TODO FMO_BUILD_VERSION
    # TODO RAV version, we will not support the hyperconfig
    # fmo-system = {
    #   RAversion = "v0.8.4";
    # };

    # TODO These should get picked up automatically by vhotplug
    ghaf.hardware.definition.usb.external = [
      {
        # PLX Technology, Inc. RNDIS/Ethernet Gadget
        # PLX Technology, Inc. Linux-USB Ethernet/RNDIS Gadget
        name = "mesh0";
        vendorId = "0525";
        productId = "a4a2";
      }
      {
        # Realtek Semiconductor Corp. USB 10/100/1000 LAN
        # Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
        name = "externalmesh0";
        vendorId = "0bda";
        productId = "8153";
      }
      # Passthrough yubikeys
      # TODO Vhotplug doesn't support wildcards, hence the patched vhotplug
      # {
      #   bus = "usb";
      #   vendorid = "1050";
      #   productid = ".*";
      # }
    ];

    ### udev rules + fmo-dynamic-device-passthrough

    # this is default? still ahci fails
    boot.initrd.availableKernelModules = [ "ahci" ];

    environment.systemPackages = [
      pkgs.vim
      pkgs.tcpdump
      pkgs.gpsd
      pkgs.natscli
    ];

    services = {

      # This enables to set dynamic port forwarding rules
      # TODO check if this is necessary and why
      # fmo-dynamic-portforwarding-service-host = {
      #   enable = true;
      #   config-paths = {
      #     netvm = "/var/netvm/netconf/dpf.config";
      #   };
      # }; # services.dynamic-portforwarding-service

      # Sets config file using fmo-tool and vhotplug.
      # We currently don't support dynamic vhotplug configuration.
      # Long term plan is to enable this through policy mechanism
      # TODO decide on re-enabling dynamic passthrough or wait for ghaf support
      # fmo-dynamic-device-passthrough-service-host = {
      #   enable = true;
      # }; # services.dynamic-device-passthrough-service-host

      # TODO check if this is required and its dependencies (fmo-config.yaml?)
      # environment.systemPackages = [ pkgs.fmo-tool ];

      # TODO should this perhaps be split to run server in admin-vm with
      # cert generation on the host?
      fmo-certs-distribution-service-host = {
        enable = true;
        ca-name = "NATS CA";
        ca-path = "/run/certs/nats/ca";
        server-ips = [
          "${hosts.ghaf-host.ipv4}"
          "127.0.0.1"
        ];
        server-name = "NATS-server";
        server-path = "/run/certs/nats/server";
        clients-paths = [
          "/run/certs/nats/clients/host"
          "/run/certs/nats/clients/netvm"
          "/run/certs/nats/clients/dockervm"
        ];
      }; # services.fmo-certs-distribution-service-host

      # TODO this needs integration and first boot or installer setup
      # registration-agent-laptop = {
      #   enable = true;
      # }; # services.registration-agent-laptop
    };

    # Create MicroVM host share folders
    systemd.tmpfiles.rules = [
      "d /persist/vms_shares/common 0700 ${toString config.ghaf.users.loginUser.uid} users -"
      "d /persist/vms_shares/dockervm 0700 ${toString config.ghaf.users.loginUser.uid} users -"
      "d /persist/vms_shares/netvm 0700 ${toString config.ghaf.users.loginUser.uid} users -"
      "d /persist/fogdata 0700 ${toString config.ghaf.users.loginUser.uid} users -"
      # TODO is this actually meant to be temporary? if yes adjust rule
      "d /persist/tmp 0700 microvm kvm -"
    ];

    # Limit the memory of the chrome-vm
    microvm.vms.chrome-vm.config.config.microvm.mem = lib.mkForce 2047;

  };
}
