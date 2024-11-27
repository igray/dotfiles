{ pkgs, unstable, lib, vars, ... }:
{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = true;

    extraPackages = with pkgs; [
      (callPackage ./neovim/vtsls/package.nix { })
      black
      elmPackages.elm-format
      elmPackages.elm-language-server
      elmPackages.lamdera
      haskellPackages.nixfmt
      lua-language-server
      markdownlint-cli
      marksman
      mdformat
      nil
      nixpkgs-fmt
      nodePackages.prettier
      nodePackages.typescript-language-server
      unstable.nodePackages.vscode-langservers-extracted
      prettierd
      shfmt
      sqlfluff
      stylua
      yaml-language-server
      zig
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig =
      let
        plugins = with pkgs.vimPlugins; [
          # LazyVim
          unstable.vimPlugins.LazyVim
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
          conform-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          fzf-lua
          unstable.vimPlugins.gitsigns-nvim
          indent-blankline-nvim
          lualine-nvim
          neo-tree-nvim
          neoconf-nvim
          neodev-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-notify
          nvim-spectre
          nvim-treesitter
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-ts-autotag
          nvim-ts-context-commentstring
          nvim-web-devicons
          persistence-nvim
          plenary-nvim
          rustaceanvim
          unstable.vimPlugins.snacks-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          unstable.vimPlugins.trouble-nvim
          vim-illuminate
          vim-startuptime
          unstable.vimPlugins.which-key-nvim
          { name = "LuaSnip"; path = luasnip; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.bufremove"; path = mini-nvim; }
          { name = "mini.comment"; path = mini-nvim; }
          { name = "mini.indentscope"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
          { name = "mini.surround"; path = mini-nvim; }
        ];
        mkEntryFromDrv = drv:
          if lib.isDerivation drv then
            { name = "${lib.getName drv}"; path = drv; }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            -- reuse files from pkgs.vimPlugins.*
            path = "${lazyPath}",
            patterns = { "." },
            -- fallback to download
            fallback = true,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- The following configs are needed for fixing lazyvim on nix
            -- force enable telescope-fzf-native.nvim
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            -- disable mason.nvim, use programs.neovim.extraPackages
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            -- Extras
            { import = "lazyvim.plugins.extras.ai.copilot" },
            { import = "lazyvim.plugins.extras.ai.copilot-chat" },
            { import = "lazyvim.plugins.extras.coding.blink" },
            { import = "lazyvim.plugins.extras.editor.navic" },
            { import = "lazyvim.plugins.extras.formatting.prettier" },
            { import = "lazyvim.plugins.extras.lang.elm" },
            { import = "lazyvim.plugins.extras.lang.gleam" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.markdown" },
            { import = "lazyvim.plugins.extras.lang.nix" },
            { import = "lazyvim.plugins.extras.lang.ruby" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.lang.sql" },
            { import = "lazyvim.plugins.extras.lang.typescript" },
            { import = "lazyvim.plugins.extras.lang.yaml" },
            { import = "lazyvim.plugins.extras.test.core" },
            -- import/override with your plugins
            { import = "plugins" },
            -- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
            { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
          },
        })
      '';
  };

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
          lua
          bash
          comment
          css
          csv
          dockerfile
          elm
          fish
          gitattributes
          gitignore
          gleam
          graphql
          html
          javascript
          jq
          json
          json5
          ledger
          lua
          make
          markdown
          markdown_inline
          nix
          query
          regex
          ron
          ruby
          rust
          scss
          sql
          toml
          typescript
          vim
          vimdoc
          yaml
        ])).dependencies;
      };
    in
    "${parsers}/parser";

  xdg.configFile."nvim/lua".source = ../nvim/lua;
}
