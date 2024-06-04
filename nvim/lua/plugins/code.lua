return {
  { "echasnovski/mini.pairs", enabled = false },
  { "tpope/vim-rails", ft = { "ruby", "eruby" } },
  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- they way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })

      opts.sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "emoji" },
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    lazy = false,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
      },
    },
  },
  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter.configs",
    dev = true,
    opts = {
      ensure_installed = {},
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        virtual_text = false,
      },
      -- make sure mason installs the server
      servers = {
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
        nil_ls = {
          settings = {
            formatting = {
              command = "nixpkgs-fmt",
            },
            nix = {
              flake = {
                autoArchive = true,
                autoEvalInputs = true,
              },
            },
          },
        },
        solargraph = {
          mason = false,
        },
        ---@type lspconfig.options.tsserver
        tsserver = {
          settings = {
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
        yamlls = {},
      },
      setup = {
        solargraph = function(_, opts)
          require("lspconfig").solargraph.setup({
            cmd = vim.lsp.rpc.connect("127.0.0.1", 7658),
            settings = {
              solargraph = {
                autoformat = false,
                completion = true,
                diagnostic = true,
                folding = true,
                formatting = true,
                references = true,
                rename = true,
                symbols = true,
              },
            },
          })
          return true
        end,
        tsserver = function(_, opts)
          require("lazyvim.util").lsp.on_attach(function(client, buffer)
            if client.name == "tsserver" then
              -- stylua: ignore
              vim.keymap.set("n", "<leader>co", "<cmd>TypescriptOrganizeImports<CR>", { buffer = buffer, desc = "Organize Imports" })
              -- stylua: ignore
              vim.keymap.set("n", "<leader>cR", "<cmd>TypescriptRenameFile<CR>", { desc = "Rename File", buffer = buffer })
            end
          end)
          require("typescript").setup({ server = opts })
          return true
        end,
      },
    },
    init = function(_)
      local status_ok, lspconfig = pcall(require, "lspconfig")
      if not status_ok then
        return
      end

      local configs = require("lspconfig.configs")
      local util = require("lspconfig.util")

      -- Check if the config is already defined (useful when reloading this file)
      if not configs.gleam then
        configs.gleam = {
          default_config = {
            cmd = { "gleam", "lsp" },
            filetypes = { "gleam" },
            root_dir = function(fname)
              return util.root_pattern("gleam.toml")(fname)
            end,
            settings = {},
          },
        }
      end

      lspconfig.gleam.setup({})

      local custom_attach = function(client)
        if client.config.flags then
          client.config.flags.allow_incremental_sync = true
        end
      end

      lspconfig.elmls.setup({
        init_options = {
          elmReviewDiagnostics = "warning",
          elmPath = "lamdera",
        },
        on_attach = custom_attach,
      })
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      languages = {
        gleam = "// %s",
      },
    },
  },
  { "williamboman/mason.nvim", enabled = false },
  { "jose-elias-alvarez/typescript.nvim" },
  {
    "NvChad/nvim-colorizer.lua",
    config = true,
  },
  {
    "mrcjkb/haskell-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim", -- Optional
    },
    branch = "2.x.x", -- Recommended
    init = function() -- Optional, see Advanced configuration
      vim.g.haskell_tools = {
        hls = {
          on_attach = function(_, bufnr)
            local ht = require("haskell-tools")
            local def_opts = { noremap = true, silent = true }
            local opts = vim.tbl_extend("keep", def_opts, { buffer = bufnr })
            -- haskell-language-server relies heavily on codeLenses,
            -- so auto-refresh (see advanced configuration) is enabled by default
            vim.keymap.set("n", "<space>ca", vim.lsp.codelens.run, opts)
            vim.keymap.set("n", "<space>hs", ht.hoogle.hoogle_signature, opts)
            vim.keymap.set("n", "<space>ea", ht.lsp.buf_eval_all, opts)
            -- Toggle a GHCi repl for the current package
            vim.keymap.set("n", "<leader>rr", ht.repl.toggle, opts)
            -- Toggle a GHCi repl for the current buffer
            vim.keymap.set("n", "<leader>rf", function()
              ht.repl.toggle(vim.api.nvim_buf_get_name(0))
            end, def_opts)
            vim.keymap.set("n", "<leader>rq", ht.repl.quit, opts)
          end,
        },
      }
    end,
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
  },
}
