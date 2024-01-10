return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    vim.keymap.set({ "i", "n", "t" }, "<c-\\>", "<cmd>ToggleTerm direction=float<cr>"),
}
