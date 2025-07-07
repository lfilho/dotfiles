-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },             -- set global limits for large files for disabling features like treesitter
      autopairs = true,                                             -- enable autopairs at start
      cmp = true,                                                   -- enable completion at start
      diagnostics = { virtual_text = false, virtual_lines = true }, -- diagnostic settings on startup
      highlighturl = true,                                          -- highlight URLs at start
      notifications = true,                                         -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = false,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    -- filetypes = {
    --   -- see `:h vim.filetype.add` for usage
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     [".foorc"] = "fooscript",
    --   },
    --   pattern = {
    --     [".*/etc/foo/.*"] = "fooscript",
    --   },
    -- },
    commands = {
      DiffOrig = {
        function()
          -- Use ":DiffOrig" to see the differences between the current buffer and the file it was loaded from.
          vim.cmd("vert new | set buftype=nofile | read ++edit # | 0d_  | diffthis | wincmd p | diffthis")
        end,
      },

      TeamMembers = {
        function()
          -- List of team members
          local team_members = {
            "'Tunji",
            "Grace",
            "Herman",
            "James",
            "Mark",
            "Patrick",
            "Sydney",
            "William",
          }

          -- Insert team names into the buffer
          local current_buf = vim.api.nvim_get_current_buf()
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          local row = cursor_pos[1] -- Current line (1-indexed)

          -- Prepare the lines to insert
          local lines_to_insert = {}
          for _, name in ipairs(team_members) do
            table.insert(lines_to_insert, "- [ ] " .. name)
          end

          -- Insert the lines at cursor position
          vim.api.nvim_buf_set_lines(current_buf, row, row, false, lines_to_insert)
        end,
      },
      -- Open a split for each dirty file in git
      OpenChangedFiles = {
        function()
          -- Get a list of changed files from Git
          local status = vim.fn.system('git status -s | grep "^ \\?\\(M\\|A\\)" | cut -d " " -f 3')
          local filenames = vim.split(status, "\n", true) -- `true` for pattern matching split

          if #filenames > 0 then
            -- Close all unmodified buffers
            vim.api.nvim_command("only")

            -- Open the first changed file in the current window
            vim.cmd("edit " .. filenames[1])

            -- Open the rest of the changed files in splits
            for i = 2, #filenames do
              vim.cmd("sp " .. filenames[i])
            end
          end
        end,
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "auto",
        showbreak = "…",
        splitright = true,
        splitbelow = true,
        wrapscan = true,
        wrap = false,
        showmatch = true,
        swapfile = false,
        backup = false,
        writebackup = false,
        undofile = true,
        smartindent = true,
        shiftwidth = 4,
        softtabstop = 4,
        tabstop = 4,
        expandtab = true,
        linebreak = true,
        foldenable = true,
        foldmethod = "manual",
        foldlevelstart = 10,
        foldnestmax = 10,
        scrolloff = 6,
        sidescrolloff = 15,
        sidescroll = 1,
        ignorecase = true,
        smartcase = true,
        updatetime = 300,
        synmaxcol = 400,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        L = {
          function()
            require("astrocore.buffer").nav(vim.v.count1)
          end,
          desc = "Next buffer",
        },
        H = {
          function()
            require("astrocore.buffer").nav(-vim.v.count1)
          end,
          desc = "Previous buffer",
        },
        ["]b"] = {
          function()
            require("astrocore.buffer").nav(vim.v.count1)
          end,
          desc = "Next buffer",
        },
        ["[b"] = {
          function()
            require("astrocore.buffer").nav(-vim.v.count1)
          end,
          desc = "Previous buffer",
        },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(function(bufnr)
              require("astrocore.buffer").close(bufnr)
            end)
          end,
          desc = "Close buffer from tabline",
        },

        ["g;"] = { "g;zz", desc = "Jump to previous position" },
        ["g,"] = { "g,zz", desc = "Jump to next position" },
        ["<C-o>"] = { "<C-o>zz", desc = "Jump to next position" },

        -- Using Perl/Python regex style by default when searching
        ["/"] = { "/\\v", desc = "Search forwards" },
        ["?"] = { "?\\v", desc = "Search backwards" },

        -- Make 0 go to the first character rather than the beginning of the line. When we're programming, we're almost always interested in working with text rather than empty space. If you want the traditional beginning of line, use ^
        ["0"] = { "^", desc = "Go to first character" },
        ["^"] = { "0", desc = "Go to beginning of line" },

        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command

        -- Quickfix list
        -- Just ported the below from the old config but right now leader - q quits the window. need to solve these conflicts
        --[[
        ["<Leader>q"] = {
          desc = "Quickfix",
        },
        ["<Leader>qc"] = {
          ":cclose<CR>",
          desc = "Close quickfix",
        },
        ["<Leader>qo"] = {
          ":copen<CR>",
          desc = "Open quickfix",
        },
        ["<Leader>qn"] = {
          ":cnext<CR>",
          desc = "Next quickfix",
        },
        ["<Leader>qp"] = {
          ":cprev<CR>",
          desc = "Previous quickfix",
        },
        ["<Leader>q/"] = {
          ":execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>",
          desc = "Quickfix search",
        },
        ]]

        -- Easier window resizing
        ["<S-Up>"] = { "<C-w>+", desc = "Increase window height" },
        ["<S-Down>"] = { "<C-w>-", desc = "Decrease window height" },
        ["<S-Left>"] = { "<C-w><", desc = "Decrease window width" },
        ["<S-Right>"] = { "<C-w>>", desc = "Increase window width" },

        -- Easier splits:
        vv = { "<C-w>v", desc = "Split vertically" },
        ss = { "<C-w>s", desc = "Split horizontally" },

        -- These are very similar keys. Typing 'a will jump to the line in the current
        -- file marked with `ma`. However, `a will jump to the line and column marked
        -- with ma.  It’s more useful in any case I can imagine, but it’s located way
        -- off in the corner of the keyboard. The best way to handle this is just to
        -- swap them: http://items.sjbach.com/319/configuring-vim-right
        ["'"] = { "`", desc = "Jump to mark" },
        ["`"] = { "'", desc = "Jump to mark" },

        -- Copying (yanking) the path of the current file in different ways:
        ["<Leader>yf"] = {
          "<cmd>let @* = expand('%:~')<cr>",
          desc = "Copy the Full path",
        },
        ["<Leader>yr"] = {
          "<cmd>let @* = expand('%')<cr>",
          desc = "Copy the Relative path",
        },
        ["<Leader>yn"] = {
          "<cmd>let @* = expand('%:t')<cr>",
          desc = "Copy the file Name",
        },

        ["<Leader>vc"] = { "yy:<C-f>p<C-c><CR>", desc = "(v)im (c)ommand - execute current line as a vim command" },

        ["p"] = { "p=`]<C-o>", desc = "Paste with auto indentation" },
        ["P"] = { "P=`]<C-o>", desc = "Paste with auto indentation" },
      },

      -- Insert mode mappings
      i = {
        -- Hashrocket
        -- FIXME: This is not working as something else is overriding it, investigate
        ["<C-l>"] = { "<Space>=><Space>", desc = "Hashrocket" },
      },

      -- Terminal mappings
      t = {
        -- ["<C-h>"] = { "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", desc = "Navigate left in tmux pane from Terminal mode" },
        -- ["<C-j>"] = { "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", desc = "Navigate down in tmux pane from Terminal mode" },
        -- ["<C-k>"] = { "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", desc = "Navigate up in tmux pane from Terminal mode" },
        -- ["<C-l>"] = { "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", desc = "Navigate right in tmux pane from Terminal mode" },
        ["<Esc>"] = {
          function()
            if vim.bo.filetype == "fzf" then
              return "<Esc>"
            else
              return "<C-\\><C-n>"
            end
          end,
        },
      },
    },
  },
}
