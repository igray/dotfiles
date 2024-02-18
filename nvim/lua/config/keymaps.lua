-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>")

vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close all to the left" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Close all to the right" })

vim.keymap.set("n", "<leader>xj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>xk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "Prev Diagnostic" })

vim.keymap.set("n", "<leader>rI", "<cmd>lua require('rspec.integrated').run_spec_file()<cr>", { desc = "RSpec this file" })
vim.keymap.set("n", "<leader>ri", "<cmd>lua require('rspec.integrated').run_spec_file({only_current_example = true})<cr>", { desc = "RSpec this example" })
vim.keymap.set("n", "<leader>r.", "<cmd>lua require('rspec.integrated').run_spec_file({repeat_last_run = true})<cr>", { desc = "RSpec repeat" })
