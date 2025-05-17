local M = {}

local dap, dapui = require("dap"), require("dapui")
dapui.setup() -- Recommended to call setup

-- You can define keymappings here
vim.keymap.set("n", "<leader>do", function() dapui.open() end, { desc = "Open DAP UI" })
vim.keymap.set("n", "<leader>dc", function() dapui.close() end, { desc = "Close DAP UI" })
vim.keymap.set("n", "<leader>dt", function() dapui.toggle() end, { desc = "Toggle DAP UI" })

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

require("which-key").add({
  {
    "<leader>d",
    group = "Debugger",
    nowait = true,
    remap = false,
  },
  {
    "<leader>dt",
    function()
      require("dap").toggle_breakpoint()
    end,
    desc = "Toggle Breakpoint",
    nowait = true,
    remap = false,
  },
  {
    "<leader>dc",
    function()
      require("dap").continue()
    end,
    desc = "Continue",
    nowait = true,
    remap = false,
  },
  {
    "<leader>di",
    function()
      require("dap").step_into()
    end,
    desc = "Step Into",
    nowait = true,
    remap = false,
  },
  {
    "<leader>do",
    function()
      require("dap").step_over()
    end,
    desc = "Step Over",
    nowait = true,
    remap = false,
  },
  {
    "<leader>du",
    function()
      require("dap").step_out()
    end,
    desc = "Step Out",
    nowait = true,
    remap = false,
  },
  {
    "<leader>dr",
    function()
      require("dap").repl.open()
    end,
    desc = "Open REPL",
    nowait = true,
    remap = false,
  },
  {
    "<leader>dl",
    function()
      require("dap").run_last()
    end,
    desc = "Run Last",
    nowait = true,
    remap = false,
  },
  {
    "<leader>dq",
    function()
      require("dap").terminate()
      require("dapui").close()
      require("nvim-dap-virtual-text").toggle()
    end,
    desc = "Terminate",
    nowait = true,
    remap = false,
  },
  {
    "<leader>db",
    function()
      require("dap").list_breakpoints()
    end,
    desc = "List Breakpoints",
    nowait = true,
    remap = false,
  },
  {
    "<leader>de",
    function()
      require("dap").set_exception_breakpoints({ "all" })
    end,
    desc = "Set Exception Breakpoints",
    nowait = true,
    remap = false,
  },
})

return M
