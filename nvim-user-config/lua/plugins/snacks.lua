return {
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        snacks_image = {
          relative = "editor",
          col = -1,
        },
      },
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = false,
          float = true,
          -- max_width = 60,
          -- max_height = 30,
        },
      },
      dashboard = {
        preset = {
          header = "🔥 Welcome back! Everything is fine! 🔥",
        },
        sections = {
          { section = "header" },
          {
            section = "terminal",
            cmd = "cat | " .. os.getenv("HOME") .. "/.config/nvim/art/this-is-fine.sh",
            height = 25,
            padding = 1,
            indent = 6,
          },

          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
