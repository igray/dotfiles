{ config, pkgs, ... }:
let
  urlFile = config.sops.secrets."alerts/healthcheck-disks".path;

  notify = pkgs.writeShellApplication {
    name = "disk-alert-notify";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      curl -fsS -m 10 --retry 5 --data-binary @- "$(cat ${urlFile})$1" > /dev/null
    '';
  };

  # mdadm passes the event name, the md device and, for some events, the component device.
  mdadmEvent = pkgs.writeShellApplication {
    name = "mdadm-event";
    runtimeInputs = [ notify ];
    text = ''
      case "$1" in
        Fail | FailSpare | DegradedArray | DeviceDisappeared | SparesMissing | TestMessage) endpoint=/fail ;;
        *) endpoint=/log ;;
      esac
      { echo "mdadm on ${config.networking.hostName}: $1 $2 ''${3:-}"; echo; cat /proc/mdstat; } \
        | disk-alert-notify "$endpoint"
    '';
  };

  smartdEvent = pkgs.writeShellApplication {
    name = "smartd-event";
    runtimeInputs = [
      notify
      pkgs.smartmontools
    ];
    text = ''
      {
        echo "$SMARTD_FULLMESSAGE"
        echo
        smartctl -H -A -d "$SMARTD_DEVICETYPE" "$SMARTD_DEVICE" || true
      } | disk-alert-notify /fail
    '';
  };

  heartbeat = pkgs.writeShellApplication {
    name = "disk-health";
    runtimeInputs = [
      notify
      pkgs.smartmontools
      pkgs.util-linux
    ];
    text = ''
      problems=""
      for mnt in /media/media /media/backup; do
        mountpoint -q "$mnt" || problems+="$mnt is not mounted"$'\n'
      done
      for md in /sys/block/md*/md; do
        name=$(basename "$(dirname "$md")")
        degraded=$(cat "$md/degraded")
        state=$(cat "$md/array_state")
        [ "$degraded" = 0 ] || problems+="$name is degraded ($degraded missing)"$'\n'
        case "$state" in
          clean | active | active-idle | write-pending) ;;
          *) problems+="$name state is $state"$'\n' ;;
        esac
        for part in "$md"/../slaves/*; do
          part=$(basename "$part")
          disk=$part
          [ -e "/sys/class/block/$part/partition" ] && disk=$(basename "$(readlink -f "/sys/class/block/$part/..")")
          rc=0
          smartctl -H -q silent "/dev/$disk" || rc=$?
          # smartctl sets bit 3 of its exit status when the drive reports itself as failing.
          (( rc & 8 )) && problems+="$disk ($name) SMART health check failed"$'\n'
        done
      done
      if [ -n "$problems" ]; then
        { printf '%s\n' "$problems"; cat /proc/mdstat; } | disk-alert-notify /fail
      else
        disk-alert-notify "" < /proc/mdstat
      fi
    '';
  };
in
{
  sops.secrets."alerts/healthcheck-disks" = { };

  boot.swraid.mdadmConf = ''
    PROGRAM ${mdadmEvent}/bin/mdadm-event
  '';
  systemd.services.mdmonitor.restartTriggers = [ config.environment.etc."mdadm.conf".text ];

  services.smartd = {
    enable = true;
    notifications.wall.enable = false;
    defaults.monitored = "-a -o on -s (S/../.././02|L/../../6/04) -m <nomailer> -M exec ${smartdEvent}/bin/smartd-event";
  };

  systemd.services.disk-health = {
    description = "Report RAID and SMART health to healthchecks.io";
    after = [ "local-fs.target" ];
    serviceConfig.Type = "oneshot";
    script = "${heartbeat}/bin/disk-health";
    startAt = "hourly";
  };
}
