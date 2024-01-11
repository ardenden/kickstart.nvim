return {
    "stevearc/oil.nvim",
    opts = {
        float = {
            max_width = 80,
            max_height = 15,
        },
        keymaps = {
            ["<leader>e"] = "actions.close",
            ["q"] = "actions.close",
        },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<cr>", { desc = "explorer" }),
}
