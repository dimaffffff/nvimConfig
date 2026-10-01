local vim = vim
local gh = function(repo)
    return "https://github.com/" .. repo
end
vim.pack.add({
	gh('sainnhe/gruvbox-material'),
	gh('folke/tokyonight.nvim'),
	gh('nvim-lualine/lualine.nvim'),
	gh('nvim-treesitter/nvim-treesitter'),
	gh('neovim/nvim-lspconfig'),
	gh('m4xshen/autoclose.nvim'),
	gh('folke/todo-comments.nvim'),
})

--GENERAL
vim.wo.number = true --line numbers
vim.wo.relativenumber = true --relative line numbers
vim.opt.swapfile = false --plain annoying
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.scrolloff = 99999999
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)--sync neovims clipboard with OS clipboard
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') --clears hl if you press esc in normal mode 

--COLORSCHEME
vim.g.gruvbox_material_background = 'hard'
vim.cmd.colorscheme("gruvbox-material")

--TODO-COMMENTS
require('todo-comments').setup { signs = false }
--AUTOCLOSE
require("autoclose").setup()

--LUALINE
require("conflualine")

--TREESITTER
require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site'
}

require('nvim-treesitter').install { 'c', 'python', 'lua' }
local fileExtensions = { 'c' , 'py' , 'lua' }

for i,v in ipairs(fileExtensions) do
	vim.api.nvim_create_autocmd('FileType', {
	  pattern = { v },
	  callback = function() vim.treesitter.start()
	  vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
	  vim.wo[0][0].foldmethod = 'expr'
	  vim.wo.foldlevel = 99 --Don't automaticaly fold everything
	  end
	})
end

--LSP
vim.lsp.inlay_hint.enable(true)
--Lua
vim.lsp.enable('lua_ls')
--C
local clangd_opts = {}
vim.lsp.enable('clangd', clangd_opts)
--Python
vim.lsp.enable('basedpyright')

--Autocompletion
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

    -- Bring completion back after backspace
    local last_len = 0

    vim.api.nvim_create_autocmd('TextChangedI', {
      buffer = ev.buf,
      callback = function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local deleted = #line < last_len
        last_len = #line

        if deleted and vim.fn.pumvisible() == 0 and line:sub(col, col):match('[%w_]') then
          vim.lsp.completion.get()
        end
      end,
    })
  end,
})

vim.opt.pumheight = 8
vim.opt.completeopt = { 'fuzzy', 'preinsert', 'noinsert','menu','menuone', 'popup' }

--General LSP config
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
})

