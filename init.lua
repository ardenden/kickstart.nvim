-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
            -- Automatically install LSPs to stdpath for neovim
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { "j-hui/fidget.nvim", opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            "folke/neodev.nvim",
        },
    },

    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",

            -- Adds a number of user-friendly snippets
            "rafamadriz/friendly-snippets",
        },
    },

    -- Useful plugin to show you pending keybinds.
    { "folke/which-key.nvim", opts = {} },

    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        "lewis6991/gitsigns.nvim",
        opts = {
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map({ "n", "v" }, "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return "<Ignore>"
                end, { expr = true, desc = "Jump to next hunk" })

                map({ "n", "v" }, "[c", function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return "<Ignore>"
                end, { expr = true, desc = "Jump to previous hunk" })

                -- Actions
                -- visual mode
                map("v", "<leader>gs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "stage hunk" })
                map("v", "<leader>gr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "reset hunk" })
                -- normal mode
                map("n", "<leader>gs", gs.stage_hunk, { desc = "stage hunk" })
                map("n", "<leader>gr", gs.reset_hunk, { desc = "reset hunk" })
                map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "unstage hunk" })
                map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
                map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
                map("n", "<leader>gp", gs.preview_hunk, { desc = "preview hunk" })
                map("n", "<leader>gb", function()
                    gs.blame_line({ full = false })
                end, { desc = "blame line" })
                map("n", "<leader>gc", function()
                    gs.diffthis("~")
                end, { desc = "compare against last commit" })
                map("n", "<leader>gC", gs.diffthis, { desc = "Compare against index" })

                -- Toggles
                map("n", "<leader>gl", gs.toggle_current_line_blame, { desc = "toggle blame line" })
                map("n", "<leader>gd", gs.toggle_deleted, { desc = "toggle show deleted" })

                -- Text object
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select hunk" })
            end,
        },
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
                    section_separators = { left = "", right = "" },
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

    {
        -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help ibl`
        main = "ibl",
        opts = {},
    },

    -- "gc" to comment visual regions/lines
    { "numToStr/Comment.nvim", opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
    },

    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",
    },

    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    { import = "custom.plugins" },
}, {})

-- [[ Setting options ]]
vim.o.hlsearch = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.o.completeopt = "menuone,noselect"

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic message" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "float" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "list" })

vim.diagnostic.config({ float = { border = "rounded" } })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

local toggle_highlight = function()
    if not vim.o.hlsearch then
        vim.o.hlsearch = true
    else
        vim.o.hlsearch = false
    end
end
vim.keymap.set("n", "<leader>h", toggle_highlight, { desc = "highlight toggle" })
vim.api.nvim_set_hl(0, "IlluminatedWordText", { bold = true, underline = true })
vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bold = true, underline = true })
vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bold = true, underline = true })
-- for ts @Decorator
vim.api.nvim_set_hl(0, "@attribute.typescript", { link = "@operator" })

-- [[ Configure Telescope ]]
require("telescope").setup({
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
})

local CallTelescope = function(input)
    local theme = require("telescope.themes").get_dropdown()
    input(theme)
end

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
    -- Use the current buffer's path as the starting point for the git search
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    -- If the buffer is not associated with a file, return nil
    if current_file == "" then
        current_dir = cwd
    else
        -- Extract the directory from the current file's path
        current_dir = vim.fn.fnamemodify(current_file, ":h")
    end

    -- Find the Git root directory from the current file's path
    local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
        print("Not a git repository. Searching on current working directory")
        return cwd
    end
    return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
    local git_root = find_git_root()
    if git_root then
        require("telescope.builtin").live_grep({
            search_dirs = { git_root },
        })
    end
end

vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

local function telescope_live_grep_open_files()
    require("telescope.builtin").live_grep({
        grep_open_files = true,
        prompt_title = "Search Open Files",
    })
end

-- See `:help telescope.builtin`
-- Find
vim.keymap.set("n", "<leader>fo", function()
    CallTelescope(require("telescope.builtin").oldfiles)
end, { desc = "old files" })
vim.keymap.set("n", "<leader>fb", function()
    CallTelescope(require("telescope.builtin").buffers)
end, { desc = "buffers" })
vim.keymap.set("n", "<leader>fs", function()
    CallTelescope(require("telescope.builtin").builtin)
end, { desc = "telescope" })
vim.keymap.set("n", "<leader>fg", function()
    CallTelescope(require("telescope.builtin").git_files)
end, { desc = "git files" })
vim.keymap.set("n", "<leader>ff", function()
    CallTelescope(require("telescope.builtin").find_files)
end, { desc = "files" })
vim.keymap.set("n", "<leader>fh", function()
    CallTelescope(require("telescope.builtin").help_tags)
end, { desc = "help" })
vim.keymap.set("n", "<leader>fw", function()
    CallTelescope(require("telescope.builtin").grep_string)
end, { desc = "word" })
vim.keymap.set("n", "<leader>fd", function()
    CallTelescope(require("telescope.builtin").diagnostics)
end, { desc = "diagnostics" })
vim.keymap.set("n", "<leader>fr", function()
    CallTelescope(require("telescope.builtin").resume)
end, { desc = "resume" })
-- Search
vim.keymap.set("n", "<leader>ss", require("telescope.builtin").live_grep, { desc = "search" })
vim.keymap.set("n", "<leader>sb", require("telescope.builtin").current_buffer_fuzzy_find, { desc = "buffer" })
vim.keymap.set("n", "<leader>so", telescope_live_grep_open_files, { desc = "open" })
vim.keymap.set("n", "<leader>sg", ":LiveGrepGitRoot<cr>", { desc = "git root" })

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

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
    require("nvim-treesitter.configs").setup({
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
            "c",
            "cpp",
            "go",
            "lua",
            "rust",
            "javascript",
            "typescript",
            "vimdoc",
            "vim",
            "bash",
        },
        sync_install = false,
        ignore_install = {},
        modules = {},
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<c-space>",
                node_incremental = "<c-space>",
                scope_incremental = "<c-s>",
                node_decremental = "<M-space>",
            },
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["aa"] = "@parameter.outer",
                    ["ia"] = "@parameter.inner",
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    ["]m"] = "@function.outer",
                    ["]]"] = "@class.outer",
                },
                goto_next_end = {
                    ["]M"] = "@function.outer",
                    ["]["] = "@class.outer",
                },
                goto_previous_start = {
                    ["[m"] = "@function.outer",
                    ["[["] = "@class.outer",
                },
                goto_previous_end = {
                    ["[M"] = "@function.outer",
                    ["[]"] = "@class.outer",
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>a"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<leader>A"] = "@parameter.inner",
                },
            },
        },
    })
end, 0)

-- [[ Configure LSP ]]
local on_attach = function()
    vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "go to definition" })
    vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "go to references" })
    vim.keymap.set("n", "gI", require("telescope.builtin").lsp_implementations, { desc = "go to Implementation" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "go to Declaration" })

    vim.keymap.set("n", "<leader>ld", require("telescope.builtin").lsp_type_definitions, { desc = "type definition" })
    vim.keymap.set("n", "<leader>ls", require("telescope.builtin").lsp_document_symbols, { desc = "document symbols" })
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "rename" })
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "action" })

    vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "symbols" })
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "add folder" })
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "remove folder" })
    vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { desc = "list folders" })

    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Documentation" })
end

-- document existing key chains
require("which-key").register({
    ["<leader>g"] = { name = "git", _ = "which_key_ignore" },
    ["<leader>f"] = { name = "find", _ = "which_key_ignore" },
    ["<leader>s"] = { name = "search", _ = "which_key_ignore" },
    ["<leader>l"] = { name = "lsp", _ = "which_key_ignore" },
    ["<leader>w"] = { name = "workspace", _ = "which_key_ignore" },
    ["<leader>d"] = { name = "diagnostics", _ = "which_key_ignore" },
})

-- register which-key VISUAL mode
require("which-key").register({
    ["<leader>"] = { name = "VISUAL <leader>" },
    ["<leader>g"] = { "hunk" },
}, { mode = "v" })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

-- Enable the following language servers
local servers = {
    rust_analyzer = {},
    tsserver = {},
    gopls = {},
    clangd = {},
    bashls = {},
    vimls = {},
    dotls = {},
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
        },
    },
}

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        })
    end,
})

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    completion = {
        completeopt = "menu,menuone,noinsert",
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
    },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
