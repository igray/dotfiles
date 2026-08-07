{
  # Loaded from conf.d, not completions/: fish only autoloads completions/<cmd>.fish
  # for commands it can resolve (PATH/function/builtin), and connect_to only ever
  # lives at bin/ssh/connect_to inside the atsnix checkout.
  xdg.configFile."fish/conf.d/connect_to-completions.fish".source = ./fish-completions/connect_to.fish;

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
        cppr = "gh pr create --head igray:(currentGitBranch)";
        gpu = "git pull origin (currentGitBranch)";
        gpf = "git push --force-with-lease";

        rebuild = {
          body = ''
            sudo nixos-rebuild switch --flake ~/Work/dotfiles; and \
              home-manager switch --flake ~/Work/dotfiles
          '';
        };
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

        # Use gcr-ssh-agent locally, but never clobber a forwarded SSH agent.
        if not set -q SSH_CONNECTION; and test -S "$XDG_RUNTIME_DIR/gcr/ssh"
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
