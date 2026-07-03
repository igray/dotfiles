{ pkgs, ... }:
{
  boot = {
    kernelParams = [
      "quiet"
      # Diagnose slow reboots: an RCU-Tasks grace period stalls the final
      # shutdown phase for minutes. These make the kernel dump the holdout
      # task(s) quickly so the culprit shows up in the next boot's journal.
      "rcupdate.rcu_task_stall_info=1"
      "rcupdate.rcu_task_stall_timeout=10"
    ];
    initrd = {
      systemd.enable = true;
    };
    plymouth.enable = true;
  };
  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
    enableRedistributableFirmware = true;
    cpu = {
      amd = {
        updateMicrocode = true;
      };
    };
    graphics = {
      # Hardware Accelerated Video
      enable = true;
    };
    bluetooth = {
      enable = true;
    };
  };
  services = {
    hardware.bolt.enable = true;
    udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl start --no-block battery-mode.service"
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start --no-block ac-mode.service"
    '';
  };

  systemd.services = {
    battery-mode = {
      description = "Switch to power-saver profile on battery";
      script = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver";
      serviceConfig.Type = "oneshot";
    };

    ac-mode = {
      description = "Switch to performance profile on AC power";
      script = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
      serviceConfig.Type = "oneshot";
    };

    power-profile-init = {
      description = "Set initial power profile based on AC status";
      after = [ "power-profiles-daemon.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        for adapter in /sys/class/power_supply/*/type; do
          if [ "$(cat "$adapter")" = "Mains" ]; then
            online=$(cat "$(dirname "$adapter")/online")
            if [ "$online" = "1" ]; then
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
            else
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
            fi
            break
          fi
        done
      '';
      serviceConfig.Type = "oneshot";
    };
  };
}
