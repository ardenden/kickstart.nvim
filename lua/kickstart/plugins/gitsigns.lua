-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
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
}
