local map = vim.keymap.set

return {
  colorscheme = "gruvbox-baby",
  highlights = {
    init = {
      VertSplit = { fg = "#777777" },
    },
  },

  plugins = {
    -- Colorschemes:
    -- TODO should we require them all below so they're easy to select later?
    { "sainnhe/sonokai" },
    { "savq/melange-nvim" },
    { "rmehri01/onenord.nvim" },
    { "luisiacc/gruvbox-baby" },
    { "jacoborus/tender.vim" },
    { "nyngwang/nvimgelion" },

    {
      "josuesasilva/vim-spell-pt-br",
      event = "VeryLazy",
    },
    {
      "echasnovski/mini.nvim",
      version = "*",
      event = "VeryLazy",
      config = function()
        local ts_spec = require("mini.ai").gen_spec.treesitter

        require("mini.surround").setup()
        require("mini.move").setup()
        require("mini.ai").setup({
          custom_textobjects = {
            b = { { "%b()", "%b[]", "%b{}" }, "^.%s*().-()%s*.$" },
            -- a = ts_spec({ a = '@parameter.outer', i = '@parameter.outer' }),
            o = ts_spec({
              a = { "@block.outer", "@conditional.outer", "@loop.outer" },
              i = { "@block.inner", "@conditional.inner", "@loop.inner" },
            }, {}),
            --
            c = ts_spec({ a = "@class.outer", i = "@class.inner" }, {}),
            x = ts_spec({ a = "@comment.outer", i = "@comment.inner" }, {}),
            f = ts_spec({ a = "@function.outer", i = "@function.inner" }),
            L = function(type)
              if vim.api.nvim_get_current_line() == "" then
                return
              end
              vim.cmd.normal({ type == "i" and "^" or "0", bang = true })
              local from_line, from_col = table.unpack(vim.api.nvim_win_get_cursor(0))
              local from = { line = from_line, col = from_col + 1 }
              vim.cmd.normal({ type == "i" and "g_" or "$", bang = true })
              local to_line, to_col = table.unpack(vim.api.nvim_win_get_cursor(0))
              local to = { line = to_line, col = to_col + 1 }
              return { from = from, to = to }
            end,
            e = function(ai_type)
              -- entire buffer
              if ai_type == "i" then
                local first_non_blank = vim.fn.nextnonblank(1)
                local final_non_blank = vim.fn.prevnonblank(vim.fn.line("$"))
                local from = { line = first_non_blank, col = 1 }
                local to = { line = final_non_blank, col = math.max(vim.fn.getline(final_non_blank):len(), 1) }

                return { from = from, to = to }
              elseif ai_type == "a" then
                local from = { line = 1, col = 1 }
                local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }

                return { from = from, to = to }
              end
            end,
          },
        })
      end,
    },
    {
      -- Preconfigured plugins from Astro community
      "AstroNvim/astrocommunity",
      { import = "astrocommunity.pack.bash" },
      { import = "astrocommunity.pack.lua" },
      { import = "astrocommunity.pack.markdown" },
      { import = "astrocommunity.pack.python" },
      { import = "astrocommunity.pack.typescript-all-in-one" },
      { import = "astrocommunity.pack.yaml" },
      { import = "astrocommunity.motion.vim-matchup" },
      -- { import = "astrocommunity.motion.mini-move" },
    },
    {
      "mattn/emmet-vim",
      event = "InsertEnter",
      ft = {
        "html",
        "css",
        "javascript",
        "javascriptreact",
        "vue",
        "typescript",
        "typescriptreact",
        "scss",
        "sass",
        "less",
        "jade",
        "haml",
        "elm",
      },
      init = function()
        vim.g.user_emmet_leader_key = ","
      end,
    },
    {
      "phaazon/hop.nvim",
      event = "VeryLazy",
      cmd = "HopWord",
      keys = { { ",s", "<cmd>HopWord<cr>", desc = "Jump to word" } },
      opts = {
        multi_windows = true,
      },
    },
    {
      -- Yank Ring
      "gbprod/yanky.nvim",
      event = { "VeryLazy" },
      config = function()
        require("yanky").setup()

        map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
        map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
        map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
        map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
        map("n", "<c-p>", "<Plug>(YankyCycleForward)")
        map("n", "<c-n>", "<Plug>(YankyCycleBackward)")
        map("n", "<leader>P", function()
          require("telescope").extensions.yank_history.yank_history({})
        end, { desc = "Paste from Yanky" })
      end,
    },
    {
      -- Navigate camel cased words
      "chaoren/vim-wordmotion",
      event = { "VeryLazy" },
      init = function()
        vim.g.wordmotion_prefix = ","
      end,
    },
    {
      -- Copy buffer as RTF
      "adah1972/vim-copy-as-rtf",
      event = { "User AstroFile" },
    },
    {
      -- Change cases and do single/plural search and replace
      "tommcdo/vim-abolish",
      cmd = { "Subvert", "Abolish" },
      keys = {
        { "crs", mode = "n" },
        { "crm", mode = "n" },
        { "crc", mode = "n" },
        { "cru", mode = "n" },
        { "cr-", mode = "n" },
        { "cr.", mode = "n" },
      },
    },
    {
      -- Split/join and case changes
      "ckolkey/ts-node-action",
      dependencies = { "nvim-treesitter" },
      event = { "CursorHold", "CursorMoved", "InsertEnter" },
      config = function()
        -- TODO lookup if there's a short cut for defining the keyamp below
        map({ "n" }, "<leader>j", require("ts-node-action").node_action, { desc = "Trigger node action" })
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            null_ls.builtins.code_actions.ts_node_action,
          },
        })
      end,
    },

    {
      -- local (per project) vim configs
      "MarcWeber/vim-addon-local-vimrc",
      event = "VeryLazy",
    },

    {
      -- Commands for easily aligning tabular data
      "godlygeek/tabular",
      event = "VeryLazy",
    },
    {
      -- Seamless navigation between vim and tmux windows
      "christoomey/vim-tmux-navigator",
      event = "VeryLazy",
    },

    {
      --VIM colon and semicolon insertion bliss Edit
      "lfilho/cosco.vim",
      ft = { "javascript", "css", "lua" },
      keys = {
        { "<Plug>(cosco-commaOrSemiColon)", mode = { "n", "i" } },
      },
      config = function()
        map({ "n", "i" }, ",;", "<Plug>(cosco-commaOrSemiColon)", { noremap = false, desc = "Insert , or ;" })
      end,
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
          dashboard.button("s", " " .. " Load last session", ":SessionManager load_last_session<CR>"),
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
        dashboard.section.terminal.command = "cat | "
            .. os.getenv("HOME")
            .. "/.config/nvim/lua/user/art/this-is-fine.sh"
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
    },
  },
}
