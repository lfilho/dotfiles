-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:
--
local map = vim.keymap.set
local cmd = vim.cmd

---@type LazySpec
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    init = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }

      local hooks = require("ibl.hooks")
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)

      require("ibl").setup({
        scope = { enabled = true },
        indent = {
          highlight = highlight,
          char = "▏",
        },
      })

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },
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

      require("mini.surround").setup({
        mappings = {
          add = "ys",
          delete = "ds",
          find = "",
          find_left = "",
          highlight = "",
          replace = "cs",
          update_n_lines = "",

          -- Add this only if you don't want to use extended mappings
          suffix_last = "",
          suffix_next = "",
        },
        search_method = "cover_or_next",
      })
      vim.keymap.del("x", "ys")
      vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

      -- Make special mapping for "add surrounding for line"
      vim.keymap.set("n", "yss", "ys_", { remap = true })

      require("mini.move").setup()
      require("mini.bracketed").setup()
      require("mini.ai").setup({
        custom_textobjects = {
          b = { { "%b()", "%b[]", "%b{}" }, "^.%s*().-()%s*.$" },
          -- a = ts_spec({ a = '@parameter.outer', i = '@parameter.outer' }),
          o = ts_spec({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          --
          c = ts_spec({
            a = "@class.outer",
            i = "@class.inner",
          }, {}),
          x = ts_spec({
            a = "@comment.outer",
            i = "@comment.inner",
          }, {}),
          f = ts_spec({
            a = "@function.outer",
            i = "@function.inner",
          }),
          L = function(type)
            if vim.api.nvim_get_current_line() == "" then
              return
            end
            cmd.normal({
              type == "i" and "^" or "0",
              bang = true,
            })
            local from_line, from_col = table.unpack(vim.api.nvim_win_get_cursor(0))
            local from = {
              line = from_line,
              col = from_col + 1,
            }
            cmd.normal({
              type == "i" and "g_" or "$",
              bang = true,
            })
            local to_line, to_col = table.unpack(vim.api.nvim_win_get_cursor(0))
            local to = {
              line = to_line,
              col = to_col + 1,
            }
            return {
              from = from,
              to = to,
            }
          end,
          e = function(ai_type)
            -- entire buffer
            if ai_type == "i" then
              local first_non_blank = vim.fn.nextnonblank(1)
              local final_non_blank = vim.fn.prevnonblank(vim.fn.line("$"))
              local from = {
                line = first_non_blank,
                col = 1,
              }
              local to = {
                line = final_non_blank,
                col = math.max(vim.fn.getline(final_non_blank):len(), 1),
              }

              return {
                from = from,
                to = to,
              }
            elseif ai_type == "a" then
              local from = {
                line = 1,
                col = 1,
              }
              local to = {
                line = vim.fn.line("$"),
                col = math.max(vim.fn.getline("$"):len(), 1),
              }

              return {
                from = from,
                to = to,
              }
            end
          end,
        },
      })
    end,
  },
  --   "tpope/vim-fugitive",
  --   event = "User AstroGitFile",
  --   dependencies = {
  --     { "tpope/vim-rhubarb" },
  --   },
  --   config = function()
  --     -- vim.api.nvim_create_autocmd("User", {
  --     --   pattern = "AstroGitFile",
  --     --   callback = function()
  --     --     -- TODO needs testing
  --     --     if string.match(vim.fn["fugitive#buffer"]().type(), "^\\%(tree\\|blob\\)$") then
  --     --       vim.api.nvim_buf_set_keymap(0, "n", "..", ":edit %:h<CR>", { buffer = true })
  --     --     end
  --     --   end,
  --     --   desc = "Go up one level on git repo",
  --     -- })
  --     vim.api.nvim_create_autocmd("BufReadPost", {
  --       pattern = "fugitive://*",
  --       callback = function()
  --         vim.opt.bufhidden = "delete"
  --
  --         if string.match(vim.fn["fugitive#buffer"]().type(), "^\\%(tree\\|blob\\)$") then
  --           vim.api.nvim_buf_set_keymap(0, "n", "..", ":edit %:h<CR>", { buffer = true, desc = "Go up one level" })
  --         end
  --       end,
  --       desc = "Prevent Fugitive from creating too many buffers",
  --     })
  --
  --     map("n", "<leader>Gd", ":Gdiffsplit<CR>", { desc = "Diff" })
  --     map("n", "<leader>Gs", ":Git<CR>", { desc = "Status" })
  --     map("n", "<leader>Gw", ":Gwrite<CR>", { desc = "Write and stage" })
  --     map("n", "<leader>Gb", ":Git blame<CR>", { desc = "Blame" })
  --     map("n", "<leader>Gco", ":Gcheckout<CR>", { desc = "Checkout" })
  --     map("n", "<leader>Gci", ":Git commit<CR>", { desc = "Commit" })
  --     map("n", "<leader>Gm", ":GMove", { desc = "Move file and rename buffer" })
  --     map("n", "<leader>Gr", ":GRemove<CR>", { desc = "Remove" })
  --
  --     map("n", "<leader>dg", ":diffget<CR>", { desc = "Diff get" })
  --     map("n", "<leader>dp", ":diffput<CR>", { desc = "Diff put" })
  --   end,
  -- },
  {
    "almo7aya/openingh.nvim",
    event = "User AstroGitFile",
    config = function()
      map("n", "<Leader>gw", ":OpenInGHRepo <CR>", {
        silent = true,
        desc = "Open Repo in GH",
      })
      map("n", "<Leader>gf", ":OpenInGHFile <CR>", {
        silent = true,
        desc = "Open File in GH",
      })
      map("v", "<Leader>gf", ":OpenInGHFile <CR>", {
        silent = true,
        desc = "Open File in GH",
      })
    end,
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
    keys = {
      { ",s", "<cmd>HopWord<cr>", desc = "Jump to word" },
    },
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
      end, {
        desc = "Paste from Yanky",
      })
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
      {
        "crs",
        mode = "n",
      },
      {
        "crm",
        mode = "n",
      },
      {
        "crc",
        mode = "n",
      },
      {
        "cru",
        mode = "n",
      },
      {
        "cr-",
        mode = "n",
      },
      {
        "cr.",
        mode = "n",
      },
    },
  },
  {
    -- Split/join
    "Wansmer/treesj",
    keys = { { "J", "<cmd>TSJToggle<CR>", desc = "Split/Join" } },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup()
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
    -- VIM colon and semicolon insertion bliss Edit
    "lfilho/cosco.vim",
    ft = { "javascript", "css", "lua" },
    keys = { {
      "<Plug>(cosco-commaOrSemiColon)",
      mode = { "n", "i" },
    } },
    config = function()
      map({ "n", "i" }, ",;", "<Plug>(cosco-commaOrSemiColon)", {
        noremap = false,
        desc = "Insert , or ;",
      })
    end,
  }, -- == Overriding Plugins ==
  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function()
      require("alpha")
      require("alpha.term")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("w", " " .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("o", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("m", " " .. " Bookmarks", ":Telescope marks <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"), -- TODO this is just the index file, prob change to user/init lua?
        dashboard.button("s", " " .. " Load last session", ':lua require("resession").load("Last Session")<CR>'),
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
      dashboard.section.terminal.command = "cat | " .. os.getenv("HOME") .. "/.config/nvim/art/this-is-fine.sh"
      dashboard.section.terminal.width = width
      dashboard.section.terminal.height = height
      dashboard.section.terminal.opts.redraw = true

      dashboard.section.header.val = "🔥 Welcome back! This is gonna be fine! 🔥"

      dashboard.config.layout = {
        {
          type = "padding",
          val = 1,
        },
        dashboard.section.terminal,
        {
          type = "padding",
          val = 8,
        },
        dashboard.section.header,
        {
          type = "padding",
          val = 2,
        },
        dashboard.section.buttons,
        {
          type = "padding",
          val = 1,
        },
        dashboard.section.footer,
      }

      return dashboard
    end,
  },
  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },
}
