{ pkgs, ... }:
{
  home.packages = [ pkgs.glow ];

  xdg.configFile."glow/glow.yml".text = ''
    pager: true
    width: 120
  '';
}
