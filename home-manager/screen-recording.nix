{ pkgs, ... }:
let
  screenrecord = pkgs.writeShellApplication {
    name = "screenrecord";
    runtimeInputs = with pkgs; [
      coreutils
      libnotify
      pulseaudio
      slurp
      wl-screenrec
      xdg-user-dirs
    ];
    text = builtins.readFile ./screenrecord.sh;
  };
in
{
  home.packages = [
    screenrecord
    pkgs.wl-screenrec
    pkgs.slurp
  ];
}
