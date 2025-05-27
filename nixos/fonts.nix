{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.mononoki
    nerd-fonts.fantasque-sans-mono
  ];
}
