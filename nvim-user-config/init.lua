local map = vim.keymap.set

return {
  colorscheme = "gruvbox-baby",
  highlights = {
    init = {
      VertSplit = { fg = '#777777' }
    }
  },

  plugins = {
    -- Colorschemes:
    { 'sainnhe/sonokai' },
    { 'savq/melange-nvim' },
    { 'rmehri01/onenord.nvim' },
    { 'luisiacc/gruvbox-baby' },
    { 'jacoborus/tender.vim' },

    {
      'AstroNvim/astrocommunity',
      { import = "astrocommunity.terminal-integration.vim-tmux-yank" },
      { import = 'astrocommunity.pack.bash' },
      { import = 'astrocommunity.pack.lua' },
      { import = 'astrocommunity.pack.markdown' },
      { import = 'astrocommunity.pack.python' },
      { import = 'astrocommunity.pack.typescript-all-in-one' },
      { import = 'astrocommunity.pack.yaml' },
      -- { import = 'astrocommunity.' },
    },
    {
      'gbprod/yanky.nvim',
      event = { "VeryLazy" },
      config = function()
        require('yanky').setup()

        map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
        map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
        map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
        map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
        map("n", "<c-p>", "<Plug>(YankyCycleForward)")
        map("n", "<c-n>", "<Plug>(YankyCycleBackward)")
        map("n", "<leader>P", function()
          require("telescope").extensions.yank_history.yank_history({})
        end, { desc = "Paste from Yanky" })
      end
    },
    {
      'chaoren/vim-wordmotion',
      event = { "VeryLazy" },
      init = function()
        vim.g.wordmotion_prefix = ","
      end
    },
    {
      'adah1972/vim-copy-as-rtf',
      event = { "User AstroFile" }
    },
    {
      'tommcdo/vim-abolish',
      cmd = { 'Subvert', 'Abolish' },
      keys = {
        { 'crs', mode = 'n' },
        { 'crm', mode = 'n' },
        { 'crc', mode = 'n' },
        { 'cru', mode = 'n' },
        { 'cr-', mode = 'n' },
        { 'cr.', mode = 'n' },
      },
    },
    {
      'ckolkey/ts-node-action',
      dependencies = { 'nvim-treesitter' },
      event = { 'CursorHold', "CursorMoved", "InsertEnter" },
      config = function()
        -- TODO lookup if there's a short cut for defining the keyamp below
        map({ "n" }, "<leader>j", require("ts-node-action").node_action, { desc = "Trigger node action" })
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            null_ls.builtins.code_actions.ts_node_action,
          }
        })
      end,
    },

    -- local (per project) vim configs
    { 'MarcWeber/vim-addon-local-vimrc', event = "VeryLazy" },

    -- Commands for easily aligning tabular data
    { 'godlygeek/tabular',               event = "InsertEnter" },
    -- Seamless navigation between vim and tmux windows
    { 'christoomey/vim-tmux-navigator',  event = "VeryLazy" },

    --VIM colon and semicolon insertion bliss Edit
    {
      'lfilho/cosco.vim',
      ft = { 'javascript', 'css', 'lua' },
      keys = {
        { '<Plug>(cosco-commaOrSemiColon)', mode = 'n' },
        { '<Plug>(cosco-commaOrSemiColon)', mode = 'i' },
      },
      config = function()
        map("n", ',;', { noremap = false, desc = 'Insert , or ;' })
        map("i", ',;', { noremap = false, desc = 'Insert , or ;' })
      end
    },
    {
      "goolord/alpha-nvim",
      opts = function()
        require("alpha")
        require("alpha.term")
        local dashboard = require("alpha.themes.dashboard")
        dashboard.section.buttons.val = {
          dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
          dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
          dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
          dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
          dashboard.button("m", " " .. " Bookmarks", ":Telescope marks <CR>"),
          dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
          dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
          dashboard.button("l", " " .. " Lazy", ":Lazy<CR>"),
          dashboard.button("q", " " .. " Quit", ":qa<CR>"),
        }
        for _, button in ipairs(dashboard.section.buttons.val) do
          button.opts.hl = "AlphaButtons"
          button.opts.hl_shortcut = "AlphaShortcut"
        end
        dashboard.section.footer.opts.hl = "Type"
        dashboard.section.header.opts.hl = "AlphaShortcut"
        dashboard.section.buttons.opts.hl = "AlphaButtons"

        local width = 46
        local height = 25 -- two pixels per vertical space
        dashboard.section.terminal.command = "cat | " ..
            os.getenv("HOME") .. "/.config/nvim/lua/user/art/this-is-fine.sh"
        dashboard.section.terminal.width = width
        dashboard.section.terminal.height = height
        dashboard.section.terminal.opts.redraw = true

        dashboard.section.header.val = "🔥 Welcome back! This is gonna be fine! 🔥"

        dashboard.config.layout = {
          { type = "padding", val = 1 },
          dashboard.section.terminal,
          { type = "padding", val = 8 },
          dashboard.section.header,
          { type = "padding", val = 2 },
          dashboard.section.buttons,
          { type = "padding", val = 1 },
          dashboard.section.footer,
        }

        return dashboard
      end,
    }
  },
}
