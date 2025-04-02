-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- There's a more lua-ish to do this but i was lazy
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "txt", "markdown", "rst", "text", "plaintex", "gitcommit" },
  group = vim.api.nvim_create_augroup("PortugueseSpell", { clear = true }),

  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en", "pt_br" }
  end,
  desc = "Enable portuguese spell check for text files",
})

-- 1-on-1s helper
local folder = "~/Documents/Notes/One-on-ones"
local group = vim.api.nvim_create_augroup("NotesAutoSplit", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  pattern = "*/One-on-ones/*",
  callback = function()
    local current_file = vim.fn.expand("%:p")
    local shared_file = vim.fn.expand(folder .. "/shared.md")
    if current_file ~= shared_file then
      vim.cmd("vsplit " .. shared_file)
    end
  end,
})
