return {
  { "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        css = { "prettierd", "prettier" },
        dart = { "dart_format" },
        elm = { "elm_format" },
        fish = { "fish_indent" },
        html = { "prettierd", "prettier" },
        gleam = { "gleam" },
        javascript = { "prettierd", "prettier" },
        lua = { "stylua" },
        markdown = { "mdformat" },
        nix = { "nixfmt" },
        python = { "black" },
        roc = { "roc" },
        ruby = { "rubocop" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        sql = { "sqlfluff" },
        typescript = { "prettierd", "prettier" },
      },
      lsp_format = "fallback",
    }
  }
}
