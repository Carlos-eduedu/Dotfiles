-- Loaded on LazyVim's VeryLazy event. Default autocmds:
-- https://www.lazyvim.org/configuration/general
local group = vim.api.nvim_create_augroup("dotfiles", { clear = true })

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  command = "wincmd =",
  desc = "Balance splits after resizing",
})
