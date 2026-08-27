-- Loaded before lazy.nvim startup. LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
local opt = vim.opt

-- Studio1804 relies on true color and restrained rounded floating borders.
opt.termguicolors = true
opt.winborder = "rounded"

-- Preserve preferences from the previous dependency-free base.
opt.relativenumber = true
opt.cursorline = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
