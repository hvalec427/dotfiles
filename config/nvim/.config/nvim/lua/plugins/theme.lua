return {
  -- Active default theme (loaded eagerly at startup).
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    opts = {
      style = "andromeda",
      transparent_background = false,
      term_colors = true,
    },
    config = function(_, opts)
      vim.g.sonokai_style = opts.style
      vim.g.sonokai_transparent_background = opts.transparent_background and 1 or 0
      vim.g.sonokai_disable_terminal_colors = opts.term_colors and 0 or 1
      vim.cmd("colorscheme sonokai")
    end,
  },

  -- Candidate themes to preview via Themery. All lazy: lazy.nvim registers each
  -- plugin's colorschemes automatically, so applying one loads its plugin.
  { "folke/tokyonight.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "loctvl842/monokai-pro.nvim", lazy = true },
  { "Mofiqul/dracula.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "scottmckendry/cyberdream.nvim", lazy = true },
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },

  -- Theme switcher: <leader>ut opens a live-preview menu; the choice persists
  -- across restarts (Themery applies it on startup, overriding sonokai above).
  {
    "zaldih/themery.nvim",
    lazy = false,
    keys = {
      { "<leader>ut", "<cmd>Themery<cr>", desc = "[u]I [t]heme picker" },
    },
    opts = {
      livePreview = true,
      themes = {
        { name = "Sonokai (Andromeda)", colorscheme = "sonokai" },
        { name = "Tokyo Night", colorscheme = "tokyonight-night" },
        { name = "Tokyo Night Storm", colorscheme = "tokyonight-storm" },
        { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
        { name = "Kanagawa Wave", colorscheme = "kanagawa-wave" },
        { name = "Kanagawa Dragon", colorscheme = "kanagawa-dragon" },
        { name = "Rosé Pine", colorscheme = "rose-pine" },
        { name = "Rosé Pine Moon", colorscheme = "rose-pine-moon" },
        { name = "Nightfox", colorscheme = "nightfox" },
        { name = "Carbonfox", colorscheme = "carbonfox" },
        { name = "Gruvbox Material", colorscheme = "gruvbox-material" },
        { name = "Everforest", colorscheme = "everforest" },
        { name = "Monokai Pro", colorscheme = "monokai-pro" },
        { name = "Monokai Pro (Spectrum)", colorscheme = "monokai-pro-spectrum" },
        { name = "Monokai Pro (Machine)", colorscheme = "monokai-pro-machine" },
        { name = "Dracula", colorscheme = "dracula" },
        { name = "One Dark", colorscheme = "onedark" },
        { name = "Cyberdream", colorscheme = "cyberdream" },
        { name = "Oxocarbon", colorscheme = "oxocarbon" },
      },
    },
  },
}
