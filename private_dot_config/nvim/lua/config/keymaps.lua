-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map <leader>cc to :CodeCompanionChat
vim.keymap.set(
  "n",
  "<leader>C",
  ":CodeCompanionChat @{full_stack_dev} #{buffer} #{lsp}<CR>",
  { desc = "CodeCompanion Chat" }
)
