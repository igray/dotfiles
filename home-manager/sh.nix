{
  programs = {
    fish = {
      enable = true;
      functions = {
        currentGitBranch = "git branch --show-current";
        gsb = {
          body = ''
            command git branch $argv
            command git checkout $argv
          '';
        };
        gpr = "git push --set-upstream origin (currentGitBranch)";

        # CareerPlug
        cpBranch = "currentGitBranch | cut -d '-' -f-2";
        cpcommit = {
          argumentNames = "message";
          body = ''
            set branch (cpBranch)
            gcm "$branch $message"
          '';
        };
        cpassets = {
          body = ''
            set branch (cpBranch)
            gcm "$branch Built Assets [assets only]"
          '';
        };
        cppr = "gh pr create --head igray:(currentGitBranch)";
        gpu = "git pull origin (currentGitBranch)";
        gpf = "git push --force-with-lease";
      };
      plugins = [
      ];
      shellAliases = {
        # ruby
        rbb = "bin/bundle";
        rbbe = "bin/bundle exec";
        rbbl = "bin/bundle list";
        rbbo = "bin/bundle open";
        rbbu = "bin/bundle update";

        # rails
        ror = "bin/rails";
        rorc = "bin/rails console";
        rordc = "bin/rails dbconsole";
        rordm = "bin/rake db:migrate";
        rordM = "bin/rake db:migrate db:test:clone";
        rordr = "bin/rake db:rollback";
        rorg = "bin/rails generate";
        rorlc = "bin/rake log:clear";
        rorp = "bin/rails plugin";
        rorr = "bin/rails runner";
        rors = "bin/rails server";
        rorsd = "bin/rails server --debugger";

        # git

        gcm = "git commit --message";
        gco = "git checkout";
        gpush = "git push";
        gb = "git branch";

        # worktrunk

        wts = "wt switch";
        wtd = "wt remove --force";

        # other
        doh = ''
          commandline -i "sudo $history[1]";history delete --exact --case-sensitive doh
        '';
        open = "xdg-open";
        ltr = "ls -l -snew";
      };
      shellInit = ''
        set -g theme_display_ruby no
        set -g theme_color_scheme solarized-dark
        set -g fish_key_bindings fish_vi_key_bindings

        # Import systemd user environment to override PAM-set SSH_AUTH_SOCK
        # This ensures we use gcr-ssh-agent instead of the non-existent gnome-keyring SSH socket
        if test -n "$XDG_RUNTIME_DIR"
          set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
        end
      '';
    };
    command-not-found.enable = true;
    dircolors = {
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
