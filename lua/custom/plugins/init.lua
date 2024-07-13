return {
    "mg979/vim-visual-multi",

    {
        "fedepujol/move.nvim",
        config = function()
            require("move").setup({
                line = {
                    enable = true, -- Enables line movement
                    indent = true, -- Toggles indentation
                },
                block = {
                    enable = true, -- Enables block movement
                    indent = true, -- Toggles indentation
                },
                word = {
                    enable = true, -- Enables word movement
                    indent = true, -- Toggles indentation
                },
                char = {
                    indent = true, -- Toggles indentation
                    enable = true, -- Enables char movement
                },
            })

            local opts = { noremap = true, silent = true }
            vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts)
            vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts)
            vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts)
            vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts)
        end,
    },

    {
        "m4xshen/autoclose.nvim",
        config = function()
            require("autoclose").setup()
        end,
    },

    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },
}
