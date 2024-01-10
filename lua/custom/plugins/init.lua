return {
    "mg979/vim-visual-multi",

    "matze/vim-move",

    {
        "m4xshen/autoclose.nvim",
        config = function()
            require("autoclose").setup()
        end,
    },
}
