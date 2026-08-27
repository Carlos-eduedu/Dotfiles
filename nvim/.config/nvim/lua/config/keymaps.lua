-- Loaded on LazyVim's VeryLazy event. Default mappings:
-- https://www.lazyvim.org/keymaps
local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR>", { desc = "Save buffer" })

local function navigate(direction, tmux_direction)
  return function()
    local window = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. direction)
    if window == vim.api.nvim_get_current_win() and vim.env.TMUX and vim.fn.executable("tmux") == 1 then
      vim.fn.system({ "tmux", "select-pane", "-" .. tmux_direction })
    end
  end
end

map("n", "<C-h>", navigate("h", "L"), { desc = "Focus left split or pane" })
map("n", "<C-j>", navigate("j", "D"), { desc = "Focus lower split or pane" })
map("n", "<C-k>", navigate("k", "U"), { desc = "Focus upper split or pane" })
map("n", "<C-l>", navigate("l", "R"), { desc = "Focus right split or pane" })
