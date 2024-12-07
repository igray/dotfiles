{ pkgs, ... }:
{
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
}
