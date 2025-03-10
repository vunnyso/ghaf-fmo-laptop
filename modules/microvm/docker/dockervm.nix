# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) optionals hasAttr;
in
{
  imports = [
    ../../fmo/dci-service
    ../../fmo/fmo-dci-passthrough
  ];

  config = {
    # Packages
    environment.systemPackages = [
      pkgs.vim
      pkgs.tcpdump
      pkgs.gpsd
      pkgs.natscli
    ];

    # Docker configuration
    virtualisation.docker.enable = true;
    virtualisation.docker.daemon.settings = {
      data-root = "/var/lib/docker";
    };

    # We use appuser in VMs
    # OLD: users.users."ghaf".extraGroups = ["docker" "dialout"];
    ghaf.users.appUser.extraGroups = [
      "docker"
      "dialout"
    ];

    # MTU
    systemd.network.links."10-ethint0".extraConfig = "MTUBytes=1372";

    # MicroVM
    microvm = {
      # TODO Should we use storagevm instead?
      volumes = [
        {
          image = "/persist/tmp/dockervm_internal.img";
          mountPoint = "/var/lib/internal";
          size = 10240;
          autoCreate = true;
          fsType = "ext4";
        }
        {
          image = "/persist/tmp/dockervm.img";
          mountPoint = "/var/lib/docker";
          size = 51200;
          autoCreate = true;
          fsType = "ext4";
        }
      ]; # microvm.volumes

      shares = [
        {
          source = "/persist/vms_shares/common";
          mountPoint = "/var/vms_share/common";
          tag = "common_share_dockervm";
          proto = "virtiofs";
          socket = "common_share_dockervm.sock";
        }
        {
          source = "/persist/vms_shares/dockervm";
          mountPoint = "/var/vms_share/host";
          tag = "dockervm_share";
          proto = "virtiofs";
          socket = "dockervm_share.sock";
        }
        {
          source = "/persist/fogdata";
          mountPoint = "/var/lib/fogdata";
          tag = "fogdatafs";
          proto = "virtiofs";
          socket = "fogdata.sock";
        }
        {
          source = "/run/certs/nats/clients/dockervm";
          mountPoint = "/var/lib/nats/certs";
          tag = "nats_dockervm_certs";
          proto = "virtiofs";
          socket = "nats_dockervm_certs.sock";
        }
        {
          source = "/run/certs/nats/ca";
          mountPoint = "/var/lib/nats/ca";
          tag = "nats_dockervm_ca_certs";
          proto = "virtiofs";
          socket = "nats_dockervm_ca_certs.sock";
        }
      ]; # microvm.shares

      # Extra args for gnss device
      qemu.extraArgs = optionals (hasAttr "gps0" config.ghaf.hardware.usb.internal.qemuExtraArgs) config.ghaf.hardware.usb.internal.qemuExtraArgs.gps0;
    }; # microvm

    # Services
    services = {

      # TODO enable monitoring service
      # fmo-monitor-service = {
      #   enable = true;
      #   nats-ip = "192.168.101.111";
      #   ca-crt-path = "/var/lib/nats/ca/ca.crt";
      #   client-key-path = "/var/lib/nats/certs/client.key";
      #   client-crt-path = "/var/lib/nats/certs/client.crt";
      #   services = [ "fmo-dci.service" ];
      #   topics = [ "dockervm/logs/fmo-dci" ];
      # };

      # TODO check how we can support dynamic hostnames
      # fmo-hostname-service = {
      #   enable = true;
      #   hostname-path = "/var/lib/fogdata/hostname";
      # }; # services.fmo-hostnam-service

      # This seems unnecessary, ghaf should handle ssh keys
      # fmo-psk-distribution-service-vm = {
      #   enable = true;
      # }; # services.fmo-psk-distribution-service-vm

      # TODO optional feature for yubikeys
      # fmo-dynamic-device-passthrough = {
      #   enable = true;
      #   devices = [
      #     # Passthrough yubikeys
      #     {
      #       bus = "usb";
      #       vendorid = "1050";
      #       productid = ".*";
      #     }
      #   ];
      # }; # services.fmo-dynamic-device-passthrough
      # fmo-dci-passthrough = {
      #   enable = true;
      #   container-name = "swarm-server-pmc01-swarm-server-1";
      #   vendor-id = "1050";
      # }; # services.fmo-dci-passthrough

      fmo-dci = {
        enable = true;
        compose-path = "/var/lib/fogdata/docker-compose.yml";
        update-path = "/var/lib/fogdata/docker-compose.yml.new";
        backup-path = "/var/lib/fogdata/docker-compose.yml.backup";
        pat-path = "/var/lib/fogdata/PAT.pat";
        preloaded-images = "tii-offline-map-data-loader.tar.gz";
        docker-url = "cr.airoplatform.com";
        docker-url-path = "/var/lib/fogdata/cr.url";
        docker-mtu = 1372;
      }; # services.fmo-dci

      avahi = {
        enable = true;
        nssmdns4 = true;
      }; # services.avahi

      # TODO enable registration
      # registration-agent-laptop = {
      #   enable = true;
      #   run_on_boot = true;
      #   certs_path = "/var/lib/fogdata/certs";
      #   config_path = "/var/lib/fogdata";
      #   token_path = "/var/lib/fogdata";
      #   hostname_path = "/var/lib/fogdata";
      #   ip_path = "/var/lib/fogdata";
      #   post_install_path = "/var/lib/fogdata/certs";
      # }; # services.registration-agent-laptop
    }; # services

    # FIXME why is this here?
    networking.firewall.enable = false;
  }; # config
}
