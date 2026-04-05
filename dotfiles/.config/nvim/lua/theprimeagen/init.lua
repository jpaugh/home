-- require("theprimeagen.set") --vim opts / settings
require("theprimeagen.remap")
require("theprimeagen.lazy_init")

function R(name)
  require("plenary.reload").reload_module(name)
end

--[[
vim.filetype.add({
  extension = {
    temp1 = 'temp1',
  }
})
--]]

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup('HighlightYank', {})
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

-- Highlight text after yanking
autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
})

-- Remove trailing spaces before saving
autocmd({'BufWritePre'}, {
  group = ThePrimeagenGroup,
  pattern = '*',
  command = [[%s/\v\s+$//e]],
})

-- Redefine code completion and code navigation keymaps when the LSP is
-- available
autocmd('LspAttach', {
  group = ThePrimeagenGroup,
  callback = function(e)
    local opts = { buffer = e.buf }

    function type_out(text)
      text_encoded = vim.api.nvim_replace_termcodes(text, true, false, true)
      vim.api.nvim_feedkeys(text_encoded, 'n', false)
    end

    -- Go to definition
    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
    -- Show hover docs for the symbol under cursor
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
    -- List all symbols in Quickfix window
    vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end)
    -- Show neovim diagnostics in a popup
    vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
    -- Select some code action at current cursor position
    vim.keymap.set('n', '<A-Enter>', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<leader>.', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<C-.>', function() vim.lsp.buf.code_action() end, opts)
    -- List all references to symbol under cursor in the the Quickfix window
    vim.keymap.set('n', '<F24>', function() vim.lsp.buf.references() end, opts)
    -- Rename all references to symbol under cursor
    vim.keymap.set('n', '<leader><C-R>', function() vim.lsp.buf.rename() end, opts)
    -- TODO: Make a rename-in-place action using vim.lsp.util.rename


    -- Display symbol's signature info in a popup
    vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
    -- Go to next diagnostic / error
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
    -- Go to previous diagnostic / error
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
  end,
})
