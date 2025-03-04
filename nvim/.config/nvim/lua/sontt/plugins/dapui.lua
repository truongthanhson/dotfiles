require("dapui").setup(
  {
    icons = { expanded = "▾", collapsed = "▸" },
    layouts = {
      {
        elements = {
          { id = "scopes", size = 1.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 10, -- columns
        position = "bottom",
      },
    },
  }
)
