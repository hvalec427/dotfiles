-- Debug Adapter Protocol: breakpoints + stop-and-inspect for JS/TS.
--
-- Plain Node/TS (Metro config scripts, Jest tests, node scripts): fully
-- working -- set a breakpoint, <leader>dc, it stops in the dap-ui panels.
--
-- React Native / Hermes attach (RN >= 0.76): handled by `metroctl`, which owns
-- the single Hermes CDP connection the fusebox inspector allows and re-exposes
-- it as a DAP server on port 9223. nvim attaches to metroctl (not Hermes
-- directly). Run metroctl against the app first (`metroctl` dashboard, or
-- `metroctl logs`), then press <leader>dr to attach — it checks the port first
-- and tells you if metroctl isn't running instead of erroring.

-- Synchronous TCP reachability check (blocks briefly, pumps the event loop so
-- the libuv connect callback can fire). Used to pre-flight the metroctl attach.
local function port_open(host, port)
  local tcp = vim.loop.new_tcp()
  local result = nil
  tcp:connect(host, port, function(err)
    result = err == nil
    pcall(function() tcp:close() end)
  end)
  vim.wait(500, function() return result ~= nil end, 10)
  if result == nil then
    pcall(function() tcp:close() end)
    return false
  end
  return result
end

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
      {
        "<leader>dr",
        function()
          if port_open("127.0.0.1", 9223) then
            require("dap").run({
              type = "metroctl",
              request = "attach",
              name = "React Native: Attach via metroctl",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
            })
          else
            vim.notify(
              "metroctl isn't running (nothing on :9223).\nStart it in your React Native project (run `metroctl`), then attach again.",
              vim.log.levels.WARN,
              { title = "React Native debug" }
            )
          end
        end,
        desc = "[d]ebug [r]eact native (metroctl)",
      },
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

      -- Don't auto-open the dap-ui panels -- keep the screen on your code when a
      -- session attaches. Toggle them yourself with <leader>du. Still tear them
      -- down on exit in case you opened them.
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

      -- React Native Hermes: attach to the DAP server metroctl runs on 9223
      -- (it owns the one Hermes CDP connection and bridges it to us). Started via
      -- <leader>dr, which pre-checks the port — so the adapter itself is a plain
      -- server connection.
      dap.adapters.metroctl = { type = "server", host = "127.0.0.1", port = 9223 }

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
          -- React Native Hermes attach is launched via <leader>dr (which
          -- pre-checks that metroctl is running), not from this picker list.
        }
      end

      local ok_wk, wk = pcall(require, "which-key")
      if ok_wk then
        wk.add({ { "<leader>d", group = "debug" } })
      end
    end,
  },
}
