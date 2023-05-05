local map = vim.keymap.set

return {
  colorscheme = "sonokai",

  plugins = {
    {
      'ckolkey/ts-node-action',
      dependencies = { 'nvim-treesitter' },
      event = { 'CursorHold', "CursorMoved", "InsertEnter" },
      config = function()
        -- TODO lookup if there's a short cut for defining the keyamp below
        vim.keymap.set({ "n" }, "<leader>j", require("ts-node-action").node_action, { desc = "Trigger node action" })
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            null_ls.builtins.code_actions.ts_node_action,
          }
        })
      end,
    },

    -- Colorscheme
    { 'sainnhe/sonokai' },

    -- local (per project) vim configs
    { 'MarcWeber/vim-addon-local-vimrc', event = "VeryLazy" },

    -- Commands for easily aligning tabular data
    { 'godlygeek/tabular' , event = "InsertEnter" },
    -- Seamless navigation between vim and tmux windows
    { 'christoomey/vim-tmux-navigator', event = "VeryLazy" },

    --VIM colon and semicolon insertion bliss Edit
    {
      'lfilho/cosco.vim',
      ft = {'javascript', 'css'},
      keys = {
        { '<Plug>(cosco-commaOrSemiColon)', desc = 'Insert Comma or Semi Colon', mode = 'n'},
        { '<Plug>(cosco-commaOrSemiColon)', desc = 'Insert Comma or Semi Colon', mode = 'i'},
      },
      config = function()
        -- TODO add to which key
        map("n", '<leader>;', '<Plug>(cosco-commaOrSemiColon)', {noremap = false})
        map("i", '<leader>;', '<c-o><Plug>(cosco-commaOrSemiColon)', {noremap = false})
      end
    },
    {
      "goolord/alpha-nvim",
      opts = function()
        require("alpha")
        require("alpha.term")
        local dashboard = require("alpha.themes.dashboard")
        dashboard.section.buttons.val = {
          dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
          dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
          dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
          dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
          dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
          dashboard.button("s", "勒" .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
          dashboard.button("l", "鈴" .. " Lazy", ":Lazy<CR>"),
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
        dashboard.section.terminal.command = "cat | " .. os.getenv("HOME") .. "/.config/nvim/lua/user/art/this-is-fine.sh"
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
