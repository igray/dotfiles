let
  email = "igray78756@gmail.com";
  name = "Iain Gray";
  user = "igray";
in {
  programs = {
    git = {
      enable = true;
      userEmail = email;
      userName = name;
      aliases = {
        pf = "push --force-with-lease";
        hard-reset = "reset --hard @{u}";
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lb = "!git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 10 | awk -F' ~ HEAD@{' '{printf(\"  \\033[33m%s: \\033[37m %s\\033[0m\\n\", substr($2, 1, length($2)-1), $1)}'";
        patch = "!git --no-pager diff";
        glog = "log --graph --decorate --oneline";
      };
      extraConfig = {
        init.defaultBranch = "main";
        fetch.prune = true;
        rebase.autosquash = true;
        url = {
          "ssh://git@github.com/" = {
            insteadOf = "https://github.com/";
          };
        };
        color.ui = true;
        core.editor = "nvim";
        credential.helper = "store";
        github.user = user;
        push.autoSetupRemote = true;
        merge.autoStash = true;
      };
      difftastic = {
        enable = true;
        background = "light";
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
    lazygit = {
      enable = true;
      settings = {
        git = {
          pagers = [
            # { useExternalDiffGitConfig = true; }
            { externalDiffCommand = "difft --color=always --background light --display side-by-side"; }
          ];
        };
      };
    };
  };
}
