local M = {}

M.defaults = {
  dir = "~/notes",         -- Notes directory
  force_slow_mode = false, -- Disables optional dependencies (fd, sd, qsv)

  -- Choose which fields appear in search results
  search_fields = {
      path      = false,
      date      = true,
      time      = false,
      sig       = false,
      title     = true,
      keywords  = true,
      ext       = false,
  },

  -- Settings for fzf-lua. See fzf-lua doc for full list of options
  fzf_lua_opts = {
    winopts = {
      height = 0.85,
      width  = 0.80,
      row    = 0.35,
      col    = 0.50,
    },
    fzf_opts = {
      ['--reverse'] = true,
      ['--no-info'] = true,
      ['--no-separator'] = true,
      ['--no-hscroll'] = true,
      ['-i'] = true,
    },
  },
}

M.options = M.defaults

return M
