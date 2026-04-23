-- mason-nvim-dap has no built-in handler for js-debug-adapter (only the old node2),
-- so we register one manually to wire up the pwa-node adapter and launch configs.
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        js = function()
          local dap = require "dap"
          dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
              command = "node",
              args = {
                vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
                "${port}",
              },
            },
          }
          local configs = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file (Node)",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to Node process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
          for _, ft in ipairs { "javascript", "typescript", "javascriptreact", "typescriptreact" } do
            dap.configurations[ft] = configs
          end
        end,
      },
    },
  },
}
