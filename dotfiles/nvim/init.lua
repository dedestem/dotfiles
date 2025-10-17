-- General settings
vim.o.number = true  -- Show line numbers

vim.api.nvim_set_keymap('n', 'f', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Install lazy.nvim if it's not installed
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/lazy.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({
    'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim.git', install_path
  })
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(install_path)

-- Setup lazy.nvim to manage plugins
require("lazy").setup({
  -- nvim-tree plugin
  {
    "kyazdani42/nvim-tree.lua",  -- The file explorer plugin
    dependencies = { "kyazdani42/nvim-web-devicons" },  -- Icons for the file explorer
    config = function()
      require("nvim-tree").setup({
        -- You can add custom nvim-tree config here
        view = {
          width = 30,
          side = "left",
        }
      })
    end
  },

  -- Add more plugins here as needed
})


