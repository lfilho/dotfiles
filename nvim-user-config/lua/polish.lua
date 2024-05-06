-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local map = vim.keymap.set
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

map("n", "[ ", "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { desc = "Put empty line above" })
map("n", "] ", "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", { desc = "Put empty line below" })

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }
