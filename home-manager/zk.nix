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
        help = "glow ~/.config/zk/cheatsheet.md";
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
      "zk-cheatsheet" = {
        target = ".config/zk/cheatsheet.md";
        text = ''
          # `zk` cheat-sheet — project aliases

          Notebook root: `~/notes` • Templates under `~/.config/zk/templates/`

          ## Create notes

          | Alias | What it does | Template |
          |---|---|---|
          | `zk daily` | New journal entry in `~/notes/journal`, filename = today's date | `journal.md` |
          | `zk ne <title>` | New idea note in `~/notes/ideas` | `default.md` |
          | `zk me <title>` | New meeting note in `~/notes/meetings`, filename = `YYYY-MM-DD-slug` | `meetings.md` |

          Note: `ne` / `me` take a raw title (not a flag). Quote multi-word titles: `zk me "Weekly 1:1"`.

          ## Browse / edit (interactive fzf picker)

          | Alias | Scope |
          |---|---|
          | `zk ls` | All notes |
          | `zk recent` | Created in the last two weeks |
          | `zk edlast` | Jump straight to most recently modified |
          | `zk t <tag>` | Notes matching a tag |
          | `zk journal` | Journal only, newest first |
          | `zk meeting` | Meetings only, newest first |
          | `zk ideas` | Ideas only, newest first |

          ## Destructive / pipeline

          | Alias | What it does |
          |---|---|
          | `zk rm [filter]` | Pick notes interactively, then `rm -vf` them |
          | `zk slides [filter]` | Pick a note, open it with `slides` |

          ## Useful built-ins (not aliased but handy)

          - `zk list --tag work` — filter by tag
          - `zk list --linked-by <path>` — backlinks
          - `zk list --match "search terms"` — full-text search
          - `zk edit --interactive --match "foo"` — fzf + search

          ## Tool config worth knowing

          - Editor: `nvim` • Pager: `less -FIRX` • fzf preview: `bat`
          - IDs: 4-char lowercase alphanum, filename `{{id}}-{{slug title}}.md`
          - Hashtags (`#foo`) and colon-tags (`:foo:`) both parsed
        '';
      };
    };
  };
}
