return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if ok then
                configs.setup({
                    ensure_installed = { "bash",
                        "c",
                        "diff",
                        "html",
                        "java",
                        "javascript",
                        "jsdoc",
                        "json",
                        "lua",
                        "luadoc",
                        "luap",
                        "markdown",
                        "markdown_inline",
                        "printf",
                        "python",
                        "query",
                        "regex",
                        "rust",
                        "toml",
                        "tsx",
                        "typescript",
                        "vim",
                        "vimdoc",
                        "xml",
                        "yaml", },
                    sync_install = false,
                    auto_install = true,
                    highlight = {
                        enable = true,
                        additional_vim_regex_highlighting = true,
                    },
                })
            end
        end,
    },
}
