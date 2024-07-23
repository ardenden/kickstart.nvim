return {
    "aktersnurra/no-clown-fiesta.nvim",
    config = function()
        require("no-clown-fiesta").setup({
            transparent = false, -- Enable this to disable the bg color
            styles = {
                comments = { italic = true },
                functions = {},
                keywords = {},
                lsp = { underline = true },
                match_paren = {},
                type = { bold = false },
                variables = {},
            },
        })
        vim.cmd([[colorscheme no-clown-fiesta]])
    end,
}
