{ ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "gleam"
      "html"
      "neosolarized"
      "ruby"
      "toml"
    ];

    # Activation merges these into ~/.config/zed/settings.json rather than
    # owning it: removing a key here does not remove it from that file.
    userSettings = {
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 15;
      ui_font_size = 16;
      theme = "NeoSolarized Dark";
      vim_mode = true;

      agent.default_model = {
        provider = "copilot_chat";
        model = "gpt-4o";
      };

      languages = {
        ERB = {
          format_on_save = "on";
          formatter = [
            {
              external = {
                command = "sh";
                arguments = [
                  "-c"
                  "f=erblinttemp_$RANDOM$RANDOM.html.erb; cat > $f; erblint -a $f &>/dev/null; cat $f; rm $f;"
                ];
              };
            }
            {
              external = {
                command = "htmlbeautifier";
                arguments = [ ];
              };
            }
          ];
        };
        Ruby.language_servers = [
          "ruby-lsp"
          "rubocop"
          "!solargraph"
        ];
      };

      lsp = {
        ruby-lsp.initialization_options.linters = [
          "rubocop"
          "reek"
        ];
        rust-analyzer.binary.path = ".devenv/profile/bin/rust-analyzer";
      };
    };
  };
}
