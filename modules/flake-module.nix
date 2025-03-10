# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
_: {
  flake.nixosModules = {
    fmo-services.imports = [
      ./fmo/dci-service
      ./fmo/dynamic-portforwarding-service
      ./fmo/fmo-certs-distribution-host
      ./fmo/fmo-dci-passthrough
    ];
    host.imports = [ ./microvm/host.nix ];
    netvm.imports = [ ./microvm/netvm.nix ];
    guivm.imports = [ ./microvm/guivm.nix ];
  };
}
