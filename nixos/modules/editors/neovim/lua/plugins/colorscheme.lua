return {
  { "ellisonleao/gruvbox.nvim", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  {
    "ishan9299/nvim-solarized-lua",
    config = function()
      vim.g.solarized_italics = 1
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}
