-- Debug Adapter Protocol: breakpoints + stop-and-inspect for JS/TS.
--
-- Plain Node/TS (Metro config scripts, Jest tests, node scripts): fully
-- working -- set a breakpoint, <leader>dc, it stops in the dap-ui panels.
--
-- React Native / Hermes attach (RN >= 0.76): a *naive* chrome/node attach does
-- NOT work -- RN dropped chrome://inspect, and the Metro inspector proxy needs
-- a specific CDP handshake. The AkisArou/nvim-dap-react-native plugin ships a
-- Node bridge that speaks that handshake (the same approach vscode-react-native
-- uses, which debugs Hermes on 0.76+ as of its v1.14.0 fix). It is wired up
-- below as the "React Native: Attach Hermes" config. Whether it drives
-- breakpoints on *this* RN version is unverified in general -- test it against
-- the running app. If it times out, React Native DevTools (press `j` in the
-- Metro terminal) remains the fallback for pausing the live UI thread.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      -- Install the vscode-js-debug adapter through Mason (package: js-debug).
      -- handlers = {} means Mason only installs it; we wire the adapters
      -- ourselves in config() so there are no surprise auto-configs.
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          ensure_installed = { "js" },
          automatic_installation = true,
          handlers = {},
        },
      },
      -- Node bridge that speaks React Native's Hermes inspector-proxy CDP
      -- handshake; provides the `reactnativedirect` adapter. `npm ci` builds it.
      { "AkisArou/nvim-dap-react-native", build = "npm ci" },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "[d]ebug [b]reakpoint toggle" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "[d]ebug conditional [B]reakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "[d]ebug [c]ontinue / start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "[d]ebug step [i]nto" },
      { "<leader>do", function() require("dap").step_over() end, desc = "[d]ebug step [o]ver" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "[d]ebug step [O]ut" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "[d]ebug [u]i toggle" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      -- Open the inspector panels on session start, tear them down on exit.
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      -- Breakpoint / stopped-line signs.
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual", numhl = "" })

      -- vscode-js-debug server, installed by Mason as the `js-debug-adapter`
      -- package. It serves both the node and chrome debug targets.
      local debug_server = vim.fn.stdpath("data")
        .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
        dap.adapters[adapter] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { debug_server, "${port}" },
          },
        }
      end

      -- React Native Hermes adapter: the same js-debug server, wrapped with the
      -- inspector-proxy handshake bridge from nvim-dap-react-native.
      dap.adapters.reactnativedirect = require("dap-react-native").create_adapter({
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { debug_server, "${port}" },
        },
      })

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
      for _, ft in ipairs(js_filetypes) do
        dap.configurations[ft] = {
          -- Works today: launch the current file as a Node process.
          {
            type = "pwa-node",
            request = "launch",
            name = "Node: Launch current file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "node",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          -- Works today: attach to an already-running Node process (pick it).
          {
            type = "pwa-node",
            request = "attach",
            name = "Node: Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          -- React Native Hermes attach. Start Metro + the app FIRST, then pick
          -- this. Uses RCT_METRO_PORT / REACT_NATIVE_PACKAGER_HOSTNAME if set,
          -- otherwise localhost:8081.
          {
            type = "reactnativedirect",
            request = "attach",
            name = "React Native: Attach Hermes",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
        }
      end

      local ok_wk, wk = pcall(require, "which-key")
      if ok_wk then
        wk.add({ { "<leader>d", group = "debug" } })
      end
    end,
  },
}
