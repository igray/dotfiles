return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_)
      local icons = require("lazyvim.config").icons

      local function fg(name)
        return function()
          ---@type {foreground?:number}?
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
        end
      end

      return {
        options = {
          component_separators = { left = "╲", right = "╱" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = fg("Statement")
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = fg("Constant") ,
            },
            { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = fg("Special") },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { "progress", separator = "", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {},
        },
        winbar = {
          lualine_c = {
            {
              function()
                return require("nvim-navic").get_location()
              end,
              cond = function()
                return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
              end,
            },
          },
        },
      }
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "cat /home/igray/.openai_key",
        api_host_cmd = "echo api.openai.com",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>oi", "<cmd>ChatGPT<cr>", desc = "Interactive Window" },
      { "<leader>oa", "<cmd>ChatGPTActAs<cr>", desc = "Act-As" },
      { "<leader>oe", "<cmd>ChatGPTEditWithInstructions<cr>", desc = "Edit with Instructions" },
      { "<leader>org", "<cmd>ChatGPTRun grammar_correction<cr>", desc = "grammar_correction" },
      { "<leader>orr", "<cmd>ChatGPTRun translate<cr>", desc = "translate" },
      { "<leader>ork", "<cmd>ChatGPTRun keywords<cr>", desc = "keywords" },
      { "<leader>ord", "<cmd>ChatGPTRun docstring<cr>", desc = "docstring" },
      { "<leader>ort", "<cmd>ChatGPTRun add_tests<cr>", desc = "add_tests" },
      { "<leader>oro", "<cmd>ChatGPTRun optimize_code<cr>", desc = "optimize_code" },
      { "<leader>ors", "<cmd>ChatGPTRun summarize<cr>", desc = "summarize" },
      { "<leader>orf", "<cmd>ChatGPTRun fix_bugs<cr>", desc = "fix_bugs" },
      { "<leader>ore", "<cmd>ChatGPTRun explain_code<cr>", desc = "explain_code" },
    },
  },
}
