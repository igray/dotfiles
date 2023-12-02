-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>")

map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close all to the left" })
map("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Close all to the right" })

map("n", "<leader>xj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", { desc = "Next Diagnostic" })
map("n", "<leader>xk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "Prev Diagnostic" })

