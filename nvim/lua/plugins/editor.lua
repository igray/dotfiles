return {
  { "folke/flash.nvim", enabled = false },
  {
    "folke/which-key.nvim",
    opts = function()
      require("which-key").add({
        { "<leader>b",  group = "Buffers" },
        { "<leader>c",  group = "Code/LSP" },
        { "<leader>f",  group = "Find" },
        { "<leader>g",  group = "Git" },
        { "<leader>q",  group = "Sessions" },
        { "<leader>s",  group = "Search" },
        { "<leader>u",  group = "UI Options" },
        { "<leader>x",  group = "Lists" },
        { "<leader><tab>",  group = "Tabs" },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 500,
        ignore_whitespace = false,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- event_handlers = {
      --   {
      --     event = "file_opened",
      --     handler = function(_)
      --       --auto close
      --       require("neo-tree").close_all()
      --     end,
      --   },
      -- },
      filesystem = {
        filtered_items = {
          always_show = { -- remains visible even if other settings would normally hide it
            "gen",
            ".elm-land",
          },
        },
      },
    },
  },
  { "ggandor/flit.nvim", enabled = false },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-d>"] = function(...)
              local action_state = require("telescope.actions.state")
              local fb = require("telescope").extensions.file_browser
              local live_grep = require("telescope.builtin").live_grep
              local current_line = action_state.get_current_line()

              fb.file_browser({
                files = false,
                depth = false,
                attach_mappings = function()
                  require("telescope.actions").select_default:replace(function()
                    local entry_path = action_state.get_selected_entry().Path
                    local dir = entry_path:is_dir() and entry_path or entry_path:parent()
                    local relative = dir:make_relative(vim.fn.getcwd())
                    local absolute = dir:absolute()

                    live_grep({
                      results_title = relative .. "/",
                      cwd = absolute,
                      default_text = current_line,
                    })
                  end)

                  return true
                end,
              })
            end,
          },
        },
      },
    },
  },
}
