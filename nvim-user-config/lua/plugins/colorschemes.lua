return {
  { "sainnhe/sonokai" },
  { "sainnhe/sonokai" },
  { "savq/melange-nvim" },
  { "projekt0n/github-nvim-theme" },
  { "EdenEast/nightfox.nvim" },
  { "folke/tokyonight.nvim" },
  { "rebelot/kanagawa.nvim" },
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({})
    end,
  },
}
