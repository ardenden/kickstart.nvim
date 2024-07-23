-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Setting options ]]
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.relativenumber = true
vim.opt.completeopt = "menuone,noselect"
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.scrolloff = 4

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldenable = false
-- vim.opt.foldnestmax = 1
-- vim.opt.foldminlines = 1
vim.opt.foldlevelstart = 99
vim.opt.foldlevel = 99
-- preserve folds
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*" },
    command = "normal zx",
})
vim.cmd([[
  autocmd BufLeave *.* mkview
  autocmd BufEnter *.* silent! loadview
]])

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic message" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "float" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "list" })

-- Buffers and Windows
vim.keymap.set("n", "<a-b>", "<c-6>")
vim.keymap.set("n", "<a-c>", "<cmd>bd<cr>")
vim.keymap.set("n", "<a-d>", "<cmd>bw<cr>")
vim.keymap.set("n", "<a-w>", "<c-w>w")
vim.keymap.set("n", "<a-h>", "<c-w>h")
vim.keymap.set("n", "<a-j>", "<c-w>j")
vim.keymap.set("n", "<a-k>", "<c-w>k")
vim.keymap.set("n", "<a-l>", "<c-w>l")
vim.keymap.set("n", "<a-q>", "<c-w>q")

vim.diagnostic.config({ float = { border = "rounded" } })

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
require("lazy").setup({
    -- Detect tabstop and shiftwidth automatically
    "tpope/vim-sleuth",

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            { "folke/neodev.nvim", opts = {} },
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    map("gd", require("telescope.builtin").lsp_definitions, "go to definition")
                    map("gr", require("telescope.builtin").lsp_references, "go to references")
                    map("gI", require("telescope.builtin").lsp_implementations, "go to Implementation")
                    map("gD", vim.lsp.buf.declaration, "go to Declaration")

                    map("<leader>ld", require("telescope.builtin").lsp_type_definitions, "type definition")
                    map("<leader>ls", require("telescope.builtin").lsp_document_symbols, "document symbols")
                    map("<leader>lr", vim.lsp.buf.rename, "rename")
                    map("<leader>la", vim.lsp.buf.code_action, "action")

                    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "symbols")
                    map("<leader>wa", vim.lsp.buf.add_workspace_folder, "add folder")
                    map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "remove folder")
                    map("<leader>wl", function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, "list folders")

                    map("K", vim.lsp.buf.hover, "Hover Documentation")
                    map("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider then
                        local highlight_augroup =
                            vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                            end,
                        })
                    end
                end,
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
            local servers = {
                clangd = {},
                gopls = {},
                pyright = {},
                rust_analyzer = {},
                tsserver = {},
                bashls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            }

            require("mason").setup()

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "stylua",
            })

            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            require("mason-lspconfig").setup({
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
        end,
    },

    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
                dependencies = {},
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
        },
        config = function()
            -- See `:help cmp`
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            luasnip.config.setup({})

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = "menu,menuone,noinsert" },

                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<tab>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete({}),
                    ["<C-l>"] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { "i", "s" }),
                    ["<C-h>"] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                },
            })
        end,
    },

    -- Useful plugin to show you pending keybinds.
    {
        "folke/which-key.nvim",
        event = "VimEnter", -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require("which-key").setup({
                preset = "helix",
            })

            -- document existing key chains
            require("which-key").add({
                { "<leader>g", group = "git" },
                { "<leader>f", group = "find" },
                { "<leader>s", group = "search" },
                { "<leader>l", group = "lsp" },
                { "<leader>w", group = "workspace" },
                { "<leader>d", group = "diagnostics" },

                { "<leader>", name = "NORMAL", mode = "n" },
                { "<leader>", name = "VISUAL", mode = "v" },
                { "<leader>g", group = "git", mode = "v" },
            })
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        config = function()
            local function show_macro_recording()
                local recording_register = vim.fn.reg_recording()
                if recording_register == "" then
                    return ""
                else
                    return "recording @" .. recording_register
                end
            end
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "auto",
                    component_separators = "|",
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_x = {
                        {
                            show_macro_recording,
                            color = { fg = "#ff9e64" },
                        },
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                },
            })
        end,
    },

    -- "gc" to comment visual regions/lines
    { "numToStr/Comment.nvim", opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
            { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
        },

        config = function()
            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require("telescope").setup({
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                defaults = {
                    sorting_strategy = "ascending",
                    preview = false,
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                        },
                    },
                },
                pickers = {
                    live_grep = {
                        theme = "dropdown",
                        preview = true,
                        layout_config = {
                            mirror = true,
                        },
                    },
                    current_buffer_fuzzy_find = {
                        theme = "dropdown",
                        preview = true,
                        layout_config = {
                            mirror = true,
                        },
                    },
                    buffers = {
                        initial_mode = "normal",
                        sort_lastused = true,
                        mappings = {
                            n = {
                                ["dd"] = require("telescope.actions").delete_buffer,
                            },
                        },
                    },
                },
                -- pickers = {}
                extensions = {
                    ["fzf"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })

            -- Enable Telescope extensions if they are installed
            pcall(require("telescope").load_extension, "fzf")

            local CallTelescope = function(input)
                local theme = require("telescope.themes").get_dropdown()
                input(theme)
            end
            -- See `:help telescope.builtin`
            local builtin = require("telescope.builtin")

            -- Find
            vim.keymap.set("n", "<leader>fo", function()
                CallTelescope(builtin.oldfiles)
            end, { desc = "old files" })
            vim.keymap.set("n", "<leader>fb", function()
                CallTelescope(builtin.buffers)
            end, { desc = "buffers" })
            vim.keymap.set("n", "<leader>fs", function()
                CallTelescope(builtin.builtin)
            end, { desc = "telescope" })
            vim.keymap.set("n", "<leader>fg", function()
                CallTelescope(builtin.git_files)
            end, { desc = "git files" })
            vim.keymap.set("n", "<leader>ff", function()
                CallTelescope(builtin.find_files)
            end, { desc = "files" })
            vim.keymap.set("n", "<leader>fh", function()
                CallTelescope(builtin.help_tags)
            end, { desc = "help" })
            vim.keymap.set("n", "<leader>fw", function()
                CallTelescope(builtin.grep_string)
            end, { desc = "word" })
            vim.keymap.set("n", "<leader>fd", function()
                CallTelescope(builtin.diagnostics)
            end, { desc = "diagnostics" })
            vim.keymap.set("n", "<leader>fr", function()
                CallTelescope(builtin.resume)
            end, { desc = "resume" })

            -- Search
            vim.keymap.set("n", "<leader>ss", builtin.live_grep, { desc = "search" })
            vim.keymap.set("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "buffer" })
            vim.keymap.set("n", "<leader>so", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                })
            end, { desc = "open" })

            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "neovim config" })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "bash", "html", "lua", "luadoc", "markdown", "go", "rust", "javascript", "typescript" },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "ruby" },
            },
            indent = { enable = true, disable = { "ruby" } },
        },
        config = function(_, opts)
            -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

            -- Prefer git instead of curl in order to improve connectivity in some environments
            require("nvim-treesitter.install").prefer_git = true
            ---@diagnostic disable-next-line: missing-fields
            require("nvim-treesitter.configs").setup(opts)

            -- There are additional nvim-treesitter modules that you can use to interact
            -- with nvim-treesitter. You should go explore a few and see what interests you:
            --
            --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
            --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
            --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
        end,
    },

    { import = "kickstart.plugins" },
    { import = "custom.plugins" },
}, {})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- for ts @Decorator
vim.api.nvim_set_hl(0, "@attribute.typescript", { link = "@operator" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
