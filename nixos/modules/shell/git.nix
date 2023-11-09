#
#  Git
#

{ config, lib, pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
    };
  };
}
