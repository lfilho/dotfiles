-- You can also add or configure plugins by creating files in this `plugins/` folder

local map = vim.keymap.set
local cmd = vim.cmd

---@type LazySpec
return {
  {
    "rareitems/printer.nvim",
    config = function()
      require("printer").setup({
        keymap = "gcl", -- Plugin doesn't have any keymaps by default
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      latex = { enabled = false },
      file_types = { "markdown", "md", "codecompanion" },
      render_modes = { "n", "no", "c", "t", "i", "ic" },
      checkbox = {
        enable = true,
        position = "inline",
      },
      code = {
        -- highlight_border = "RenderMarkdownBullet",
        highlight_border = "Folded",
        sign = false,
        border = "thin",
        position = "right",
        width = "block",
        above = "▁",
        below = "─",
        language_left = "█",
        language_right = "█",
        language_border = "─",
        left_pad = 1,
        right_pad = 1,
      },
      heading = {
        width = "block",
        backgrounds = {
          "MiniStatusLineModeNormal",
          "MiniStatusLineModeInsert",
          "MiniStatusLineModeOther",
          "MiniStatusLineModeReplace",
          "MiniStatusLineModeCommand",
          "MiniStatusLineModeVisual",
        },
        sign = false,
        left_pad = 1,
        right_pad = 0,
        position = "right",
        icons = {
          "",
          "",
          "",
          "",
          "",
          "",
        },
        -- icons = {
        --   " ",
        --   " ",
        --   " ",
        --   " ",
        --   " ",
        --   " ",
        -- },
        -- icons = {
        --   "█ ",
        --   "██ ",
        --   "███ ",
        --   "████ ",
        --   "█████ ",
        --   "██████ ",
        -- },
      },
    },
  },
  {
    -- For local development use:
    -- dir = "~/work/note2cal.nvim",
    "lfilho/note2cal.nvim",
    config = function()
      require("note2cal").setup({
        debug = false,
        calendar_name = "Work",
        highlights = {
          at_symbol = "WarningMsg",
          at_text = "Number",
        },
      })
    end,
    ft = "markdown",
  },
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
          char = "│",
        },
      })

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
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
    "smoka7/hop.nvim",
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
        require("snacks").picker.yanky()
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
      require("treesj").setup({
        on_error = function()
          vim.cmd.join()
        end,
      })
    end,
  },
  {
    -- Commands for easily aligning tabular data
    "godlygeek/tabular",
    event = "VeryLazy",
  },
  {
    -- VIM colon and semicolon insertion bliss
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
  },
  -- { "wuelnerdotexe/vim-astro" }, --  TODO: test if it works by default now, if not, remove this line
  -- { "virchau13/tree-sitter-astro" }, --  TODO: test if it works by default now, if not, remove this line
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    cmd = { "PasteImage", "ImgClipDebug", "ImgClipConfig" },
    opts = {
      default = {
        dir_path = "images",
        file_name = function()
          return vim.fn.expand("%:t:r") .. "__" .. "%Y-%m-%d-%H-%M-%S"
        end,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        relative_to_current_file = true,
      },
    },
    keys = {
      { "<leader>up", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit", "scratch" },
    config = function()
      -- Disable default key mappings
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit", "scratch" }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<CR>", "<Plug>(bullets-toggle-checkbox)", {
            buffer = true,
            silent = true,
          })
        end,
      })
    end,
  },
}
