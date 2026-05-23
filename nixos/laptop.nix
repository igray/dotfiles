{ pkgs, ... }:
{
  boot = {
    # MT7922 bluetooth ("Failed to send wmt func ctrl (-22)") regressed in the
    # stable 6.18 series between 6.18.26 (good) and 6.18.31/.32 (broken): the
    # btmtk driver started rejecting too-short WMT FUNC_CTRL events. Firmware is
    # unchanged. Cherry-pick the upstream fix until it lands in a stable release
    # (expected 6.18.33+). See https://github.com/NixOS/nixpkgs/issues/521528
    # Remove this patch once nixpkgs ships a kernel that already contains it.
    kernelPatches = [
      {
        name = "Bluetooth: btmtk: accept too short WMT FUNC_CTRL events";
        patch = pkgs.fetchurl {
          url = "https://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git/patch/?id=162b1adeb057d28ad84fd8a03f3c50cf08db5c62";
          hash = "sha256-ij0hQmC0U++AdXWQy6nycnDe6z4yaMoQIrSiLal5DHc=";
        };
      }
    ];
    kernelParams = [ "quiet" ];
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
