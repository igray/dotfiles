#
#  Shell
#

{ pkgs, vars, ... }:

{
  programs = {
    fish = {
      enable = true;
    };
  };
  users.users.${vars.user} = {
    shell = pkgs.fish;
  };
  home-manager.users.${vars.user} = {
    programs = {
      fish = {
        enable = true;
        functions = {
          currentGitBranch = "git branch | grep '\*' | awk -e '{ print $2 }'";
          gsb = {
            body = ''
              command git branch $argv
              command git checkout $argv
            '';
          };

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
          ciboost = {
            body = ''
              set branch (currentGitBranch)
              if test "$branch" = "main"
                echo "You are on main branch, please checkout to a feature branch"
                return 1
              end
              gco main
              gpu
              gco "$branch"
              git rebase main
              git show -s --format=%B | sed '1 s/\( \[ciboost\]\)\?$/ [ciboost]/' | git commit --amend -F -
              gpf
            '';
          };
        };
        plugins = [
        ];
        shellAliases = {
          # ruby
          rbb = "bundle";
          rbbe = "bundle exec";
          rbbl = "bundle list";
          rbbo="bundle open";
          rbbu="bundle update";

          # rails
          ror="bundle exec rails";
          rorc="bundle exec rails console";
          rordc="bundle exec rails dbconsole";
          rordm="bundle exec rake db:migrate";
          rordM="bundle exec rake db:migrate db:test:clone";
          rordr="bundle exec rake db:rollback";
          rorg="bundle exec rails generate";
          rorlc="bundle exec rake log:clear";
          rorp="bundle exec rails plugin";
          rorr="bundle exec rails runner";
          rors="bundle exec rails server";
          rorsd="bundle exec rails server --debugger";

          # git

          gcm="git commit --message";
          gco="git checkout";
          gpush="git push";
          gb="git branch";

          # other
          doh=''
            commandline -i "sudo $history[1]";history delete --exact --case-sensitive doh
          '';
        };
        shellInit = ''
          set -g theme_display_ruby no
          set -g theme_color_scheme solarized-dark
        '';
      };
      command-not-found = {
        enable = true;
      };
    };
  };
}
