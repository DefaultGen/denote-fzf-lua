local M = {}

M.defaults = {
  dir = "~/notes", 
  window = {
    width_percent = 80,
    height_percent = 80,
    x_offset = 0,
    y_offset = 0,
  },
  fzf = {
    opts = {
      ['--reverse'] = true,
      ['--no-info'] = true,
      ['--no-separator'] = true,
      ['--no-hscroll'] = true,
      ['--preview-window'] = "bottom:50%",
      ['-i'] = true,
      ['--delimiter'] = "\\s{2,}",
      ['--header-lines'] = 1
    },
    search_fields = {
      path  = false,
      date  = true,
      time  = false,
      sig   = false,
      title = true,
      tags  = true,
      ext   = false,
    },
    -- This recombines the chopped up filename from ./scripts/search_files.sh and outputs it to cat
    -- TODO: Rewrite this with a lua function
    preview = [[\
sig={4};   sig=$(echo   $sig   | sd "\W" "" | sd " " "="); if [ ! -z ${sig} ]   ; then sig="==${sig}";     fi; \
title={5}; title=$(echo $title | tr -d '.'  | tr ' ' '-'); if [ ! -z ${title} ] ; then title="--${title}"; fi; \
tags={6};  tags=$(echo  $tags  | tr -d '.'  | tr ' ' '_'); if [ ! -z ${tags} ]  ; then tags="__${tags}";   fi; \
ext={7}; \
echo {1}\|{2}\|{3}\|{4}\|{5}\|{6}\|{7} | \
sd "(?P<path>\/.*\/)?\|(?P<d1>\d\d\d\d)-(?P<d2>\d\d)-(?P<d3>\d\d)\|(?P<t1>\d\d):(?P<t2>\d\d):(?P<t3>\d\d)\|.*" "\$path\$d1\$d2\${d3}T\$t1\$t2\$t3$sig$title$tags$ext" |\
xargs cat]],
    -- selected[1] is the chopped up filename with 2+ spaces between fields
    actions = {
      ['default'] = function(selected, opts)
          require'denote-fzf-lua'.open_file(selected[1])
        end
    }
  }
}

M.options = M.defaults

return M
