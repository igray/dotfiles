-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.cmd("hi IndentBlanklineChar guifg=#073642 gui=nocombine")
    vim.cmd("hi IndentBlanklineContextChar guifg=#586e75 gui=nocombine")
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    vim.cmd("hi ColorColumn guibg=#002933 gui=nocombine")
  end,
})
