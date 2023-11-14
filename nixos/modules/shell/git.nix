#
#  Git
#

{ config, lib, pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    programs = {
      git = {
        enable = true;
        userEmail = "igray78756@gmail.com";
        userName = "Iain Gray";
        aliases = {
          pf = "push --force-with-lease";
          hard-reset = "reset --hard @{u}";
          co = "checkout";
          br = "branch";
          ci = "commit";
          st = "status";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          patch = "!git --no-pager diff";
          glog = "log --graph --decorate --oneline";
        };
        extraConfig = {
          init = {
            defaultBranch = "main";
          };
          fetch = {
            prune = true;
          };
          rebase = {
            autosquash = true;
          };
          url = {
            "ssh://git@github.com/" = {
              insteadOf = "https://github.com/";
            };
          };
        };
        delta = {
          enable = true;
        };
      };
      gitui = {
        enable = true;
      };
      gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
          pager = "bat";
          aliases = {
            co = "pr checkout";
            pv = "pr view -w";
            pcr = "pr create -d -f";
          };
        };
      };
    };
  };
}
