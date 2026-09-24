{ pkgs, ... }:
let
  # RADV is the only GPU backend that fits this box: the ONNX engines (parakeet,
  # moonshine, ...) are CUDA/MIGraphX-oriented and are left out of the build.
  voxtype = pkgs.voxtype.override { vulkanSupport = true; };
in
{
  home.packages = [ voxtype ];

  xdg.configFile."voxtype/config.toml".text = ''
    state_file = "auto"

    [hotkey]
    enabled = false

    [audio]
    device = "default"
    sample_rate = 16000
    max_duration_secs = 120
    pause_media = true

    [whisper]
    mode = "local"
    model = "small.en"
    language = "en"
    translate = false
    on_demand_loading = false

    [output]
    mode = "type"
    fallback_to_clipboard = true
    type_delay_ms = 0
  '';

  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype push-to-talk dictation daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${voxtype}/bin/voxtype daemon";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
