return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["s"] = "open_split",    -- horizontal (was S)
        ["S"] = false,           -- disable old uppercase-S horizontal
        ["v"] = "open_vsplit",   -- vertical (new; was lowercase-s)
        ["<C-s>"] = "open_split",
        ["<C-v>"] = "open_vsplit",
      },
    },
  },
}
