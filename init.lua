-----------------------------------------------------------
-- 🧠 Fully-Loaded Neovim Config (VSCode-style)
-----------------------------------------------------------

-- 🧩 Bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- ⚙️ Plugins
-----------------------------------------------------------
require("lazy").setup({

  ---------------------------------------------------------
  -- Icons (MUST be loaded first)
  ---------------------------------------------------------
  { "nvim-tree/nvim-web-devicons", config = true },

  ---------------------------------------------------------
  -- UI / Appearance
  ---------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
      })
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-treesitter/playground" },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },

  ---------------------------------------------------------
  -- LSP + Completion + Snippets
  ---------------------------------------------------------
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvimdev/lspsaga.nvim" },

  ---------------------------------------------------------
  -- Formatting / Linting
  ---------------------------------------------------------
  { "jose-elias-alvarez/null-ls.nvim" },

  ---------------------------------------------------------
  -- Git / Utilities
  ---------------------------------------------------------
  { "lewis6991/gitsigns.nvim", config = true },
  { "numToStr/Comment.nvim", config = true },
})

-----------------------------------------------------------
-- 🧾 Basic Settings
-----------------------------------------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.termguicolors = true
vim.cmd.colorscheme("tokyonight")
vim.g.mapleader = " "
vim.opt.list = false

-----------------------------------------------------------
-- 🖋 Encoding + Font
-----------------------------------------------------------
vim.opt.fillchars = { eob = " " }

-- Safe encoding settings
pcall(function() vim.opt.encoding = "utf-8" end)
pcall(function() vim.opt.fileencoding = "utf-8" end)

-- Only GUI clients (like Neovide) support guifont
if vim.fn.has("gui_running") == 1 then
  pcall(function() vim.opt.guifont = "FiraCode Nerd Font:h12" end)
end

vim.g.airline_powerline_fonts = 1

-----------------------------------------------------------
-- 🌳 Treesitter
-----------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "go", "lua", "python", "rust", "javascript", "html", "css" },
  highlight = { enable = true },
  indent = { enable = true },
})

-----------------------------------------------------------
-- 📦 Mason + LSP (Neovim 0.11+ API)
-----------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright", "gopls", "rust_analyzer", "ts_ls", "clangd", "lua_ls"
  }
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Configure all servers
for _, server in ipairs({ "pyright", "gopls", "rust_analyzer", "ts_ls", "clangd", "lua_ls" }) do
  vim.lsp.config[server] = { capabilities = capabilities }
end

-- Special config for lua_ls to recognize 'vim' global
vim.lsp.config.lua_ls.settings = {
  Lua = {
    diagnostics = { globals = { "vim" } }
  }
}

-- Enable all servers
vim.lsp.enable({ "pyright", "gopls", "rust_analyzer", "ts_ls", "clangd", "lua_ls" })

-----------------------------------------------------------
-- 🤖 Autocomplete (nvim-cmp)
-----------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  preselect = cmp.PreselectMode.Item,
  completion = { completeopt = "menu,menuone" },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-----------------------------------------------------------
-- 🔍 Telescope
-----------------------------------------------------------
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)

-----------------------------------------------------------
-- 🌲 NvimTree
-----------------------------------------------------------
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-----------------------------------------------------------
-- ✨ QoL Plugins
-----------------------------------------------------------
require("Comment").setup()
require("gitsigns").setup()

-----------------------------------------------------------
-- 🧠 VSCode-style snippets
-----------------------------------------------------------
require("luasnip.loaders.from_vscode").lazy_load()
vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"
