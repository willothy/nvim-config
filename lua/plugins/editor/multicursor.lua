return {
  {
    "mg979/vim-visual-multi",
    event = "User ExtraLazy",
    enabled = false,
    config = function()
      vim.api.nvim_exec2(
        [[
  let g:VM_mouse_mappings = 1
  let g:VM_maps['Find Under']                  = '<C-n>'
  " let g:VM_maps['Find Subword Under']          = '<C-n>'
  let g:VM_maps["Select All"]                  = '\\A'
  let g:VM_maps["Start Regex Search"]          = '\\/'
  let g:VM_maps["Add Cursor Down"]             = '<C-j>'
  let g:VM_maps["Add Cursor Up"]               = '<C-k>'
  let g:VM_maps["Add Cursor At Pos"]           = '\\\'

  let g:VM_maps["Visual Regex"]                = '\\/'
  let g:VM_maps["Visual All"]                  = '\\A'
  let g:VM_maps["Visual Add"]                  = '\\a'
  let g:VM_maps["Visual Find"]                 = '\\f'
  let g:VM_maps["Visual Cursors"]              = '\\c'
      ]],
        {}
      )
    end,
  },
}
