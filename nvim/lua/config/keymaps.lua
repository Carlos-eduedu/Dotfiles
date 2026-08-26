-- Loaded on LazyVim's VeryLazy event. Default mappings:
-- https://www.lazyvim.org/keymaps
local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR>", { desc = "Save buffer" })
map("n", "<C-h>", "<C-w>h", { desc = "Focus left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right split" })
