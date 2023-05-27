return {
  {
    "folke/which-key.nvim",
    opts = function()
      require("which-key").register({
        ["<leader>o"] = { name = "+ChatCPT" },
        ["<leader>or"] = { name = "+Run" },
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
      current_line_blame_formatter_opts = {
        relative_time = true,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      event_handlers = {
        {
          event = "file_opened",
          handler = function(_)
            --auto close
            require("neo-tree").close_all()
          end,
        },
      },
    },
  },
  { "ggandor/flit.nvim", enabled = false },
}
