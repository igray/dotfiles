{ pkgs, ... }:
{
  home.packages = with pkgs; [
    android-studio
    android-tools
  ];

  home.file = {
    "idea.properties".text = "idea.filewatcher.executable.path = ${pkgs.fsnotifier}/bin/fsnotifier";
  };
}
