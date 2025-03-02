vim.opt.termguicolors = true      -- Enable true color support
vim.opt.background = "dark"      -- Set background mode (dark/light based on terminal)

-- Make the background transparent
vim.cmd [[highlight Normal guibg=NONE ctermbg=NONE guifg=#ffffff]]
vim.cmd [[highlight NonText guibg=NONE ctermbg=NONE guifg=#ffffff]]

-- Enable line numbers
vim.opt.number = true

-- Set line number color
vim.cmd [[highlight LineNr guifg=#b000ff]]

-- Optional: Enable relative line numbers
-- vim.opt.relativenumber = true

-- Ensure the UI updates correctly
vim.cmd [[autocmd VimEnter * hi Normal ctermbg=NONE guibg=NONE guifg=#ffffff]]
