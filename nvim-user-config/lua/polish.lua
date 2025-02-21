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

--
-- Auto Wrapping for certain file types:
--
-- Define the function to set up wrapping
local function setup_wrapping()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.list = false
  vim.opt_local.showbreak = "…"
end

-- Apply wrapping automatically to specific file types
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "tex", "markdown", "text" },
  callback = function()
    setup_wrapping()
  end,
})

-- Create a command for manual wrapping
vim.api.nvim_create_user_command("Wrap", setup_wrapping, { nargs = "*" })

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
