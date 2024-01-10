return {
    "RRethy/vim-illuminate",
    config = function()
        require("illuminate").configure({
            providers = {
                "treesitter",
                "lsp",
                "regex",
            },
            delay = 10,
        })
    end,
}
