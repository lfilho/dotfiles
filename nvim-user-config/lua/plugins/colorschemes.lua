return {
  -- TODO: should we require them all below so they're easy to select later?
  { "sainnhe/sonokai" },
  { "savq/melange-nvim" },
  { "projekt0n/github-nvim-theme" },
  {
    "luisiacc/gruvbox-baby",
    init = function()
      local c = require("gruvbox-baby.colors").config()
      -- Customizing Telescope
      vim.g.gruvbox_baby_highlights = {
        TelescopePreviewTitle = {
          fg = c.background,
          bg = c.forest_green,
        },
        TelescopePromptTitle = {
          fg = c.background,
          bg = c.soft_yellow,
        },
        TelescopeResultsTitle = {
          fg = c.background_dark,
          bg = c.milk,
        },
      }
    end,
  },
  { "nyngwang/nvimgelion" },
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({})
    end,
  },
}
