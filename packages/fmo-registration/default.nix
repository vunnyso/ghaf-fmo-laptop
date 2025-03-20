# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  writeShellApplication,
  registration-agent,
}:
writeShellApplication {
  name = "fmo-registration";

  runtimeInputs = [
    registration-agent
  ];

  text = ''
    echo "FMO latop registration is a privileged operation. Enter password to proceed."
    /run/wrappers/bin/sudo /run/current-system/sw/bin/registration-agent-laptop
  '';

  meta = {
    description = "Wrapper script for registration agent.";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
