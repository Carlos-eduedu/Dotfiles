return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
      },
      on_colors = function(colors)
        colors.bg = "#000000"
        colors.bg_dark = "#000000"
        colors.bg_float = "#1f2937"
        colors.bg_highlight = "#1f2937"
        colors.bg_popup = "#1f2937"
        colors.bg_sidebar = "#000000"
        colors.bg_statusline = "#1f2937"
        colors.border = "#374151"
        colors.fg = "#ffffff"
        colors.fg_dark = "#9ca3af"
        colors.fg_float = "#ffffff"
        colors.fg_gutter = "#374151"
        colors.comment = "#6b7280"
        colors.orange = "#f97316"
        colors.yellow = "#eab308"
        colors.green = "#22c55e"
        colors.red = "#ef4444"
        colors.error = "#ef4444"
        colors.warning = "#eab308"
        colors.info = "#38bdf8"
        colors.hint = "#38bdf8"
        colors.blue = "#38bdf8"
        colors.blue1 = "#7dd3fc"
        colors.blue2 = "#38bdf8"
        colors.blue5 = "#9ca3af"
        colors.magenta = "#fb923c"
        colors.purple = "#d1d5db"
        colors.teal = "#22d3ee"
      end,
      on_highlights = function(highlights, colors)
        highlights.CursorLine = { bg = colors.bg_highlight }
        highlights.FloatBorder = { fg = colors.border, bg = colors.bg_float }
        highlights.WinSeparator = { fg = colors.border }
        highlights.Visual = { bg = "#374151" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
