{ pkgs, ... }:
{
  plugins.cmp-emoji.enable = true;
  plugins.conform-nvim = {
    settings = {
      formatters_by_ft = {
        dart = [ "dart_format" ];
        elm = [ "elm_format" ];
        fish = [ "fish_indent" ];
        gleam = [ "gleam" ];
        roc = [ "roc" ];
        ruby = [ "rubocop" ];
        sh = [ "shfmt" ];
        sql = [ "sqlfluff" ];
      };
    };
  };
  plugins.lsp = {
    servers = {
      bashls = {
        enable = true;
      };
      cssls = {
        enable = true;
      };
      dartls = {
        enable = true;
      };
      dockerls = {
        enable = true;
      };
      elmls = {
        enable = true;
      };
      fish_lsp = {
        enable = true;
        package = pkgs.fish-lsp;
      };
      gleam = {
        enable = true;
      };
      html = {
        enable = true;
      };
      jsonls = {
        enable = true;
      };
      roc_ls = {
        enable = false;
      };
      ruby_lsp = {
        enable = true;
      };
      yamlls = {
        enable = true;
      };
    };
  };
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "vim-rails";
      src = pkgs.fetchFromGitHub {
        owner = "tpope";
        repo = "vim-rails";
        rev = "d3954dfe3946c9330dc91b4fbf79ccacb2c626c0";
        hash = "sha256-p3V8kndHjna9ujy9JQijrHFR6odcFPp1VSZwtgtQxCw=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "flutter-tools";
      src = pkgs.fetchFromGitHub {
        owner = "nvim-flutter";
        repo = "flutter-tools.nvim";
        rev = "818ad42b204cda5317baa399377ea30b35f6f8be";
        hash = "sha256-xHb0vCXnK7VZv+3L0+0F4yWExiOri5QGGRyx1aqqUMc=";
      };
    })
  ];
}
