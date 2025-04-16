{ vars, ... }:
let
  notebook = "/home/${vars.username}/notes";
in
{
  programs.zk = {
    enable = true;
    settings = {
      notebook = {
        dir = notebook;
      };
      note = {
        language = "en";
        default-title = "Untitled";
        filename = "{{id}}-{{slug title}}";
        extension = "md";
        template = "default.md";
        id-charset = "alphanum";
        id-length = 4;
        id-case = "lower";
      };
      extra = {
        author = "Iain";
      };
      group = {
        meetings = {
          paths = [ "meetings" ];
          note = {
            filename = "{{format-date now}}-{{slug title}}";
            template = "meetings.md";
          };
        };
        journal = {
          paths = [ "journal" ];
          note = {
            filename = "{{format-date now}}";
            template = "journal.md";
          };
        };
      };
      format = {
        markdown = {
          hashtags = true;
          colon-tags = true;
        };
      };
      tool = {
        editor = "nvim";
        pager = "less -FIRX";
        fzf-preview = "bat -p --color always {-1}";
      };
      filter = {
        recents = "--sort created- --created-after 'last two weeks'";
      };
      alias = {
        edlast = "zk edit --limit 1 --sort modified- $@";
        recent = "zk edit --sort created- --created-after 'last two weeks' --interactive";
        ls = "zk edit --interactive";
        t = "zk edit --interactive --tag $argv";
        daily = "zk new --no-input \"${notebook}/journal\"";
        ne = "zk new --no-input \"${notebook}/ideas\" --title $argv";
        me = "zk new --no-input \"${notebook}/meetings\" --title $argv";
        meeting = "zk edit \"${notebook}/meetings\" --sort created- --interactive";
        journal = "zk edit --sort created- ${notebook}/journal --interactive";
        ideas = "zk edit --sort created- ${notebook}/ideas --interactive";
        rm = "zk list --interactive --quiet --format path --delimiter0 $argv | xargs -0 rm -vf --";
        slides = "zk list --interactive --quiet --format path --delimiter0 $argv | xargs -0 slides";
      };
      lsp = {
        diagnostics = {
          wiki-title = "hint";
          dead-link = "error";
        };
      };
    };
  };
  home = {
    file = {
      "zk-templates-default" = {
        target = ".config/zk/templates/default.md";
        text = ''
          ---
          title: {{ title }}
          date: {{ format-date now 'long' }}
          tags: []
          ---
        '';
      };
      "zk-templates-journal" = {
        target = ".config/zk/templates/journal.md";
        text = ''
          ---
          date: {{ format-date now 'long' }}
          tags: []
          ---
        '';
      };
      "zk-templates-meetings" = {
        target = ".config/zk/templates/meetings.md";
        text = ''
          ---
          date: {{ format-date now 'long' }}
          tags: [{{ slug title }}]
          ---
        '';
      };
    };
  };
}
