local M = {}

M.defaults = {
  dir = "~/notes",
  force_slow_mode = false, -- Disables optional dependencies

  -- Set any fzf-lua winopts here (See fzf-lua documentation)
  winopts = {
    height = 0.85,
    width  = 0.80,
    row    = 0.35,
    col    = 0.50,
  },

  -- Options sent to fzf (only relevant for filename search)
  fzf = {
    opts = {
      ['--reverse'] = true,
      ['--no-info'] = true,
      ['--no-separator'] = true,
      ['--no-hscroll'] = true,
      ['--preview-window'] = "bottom:50%",
      ['-i'] = true,
      ['--delimiter'] = "\\s{2,}", -- Don't change this, change search_fields.
    },
    -- Which Denote fields are displayed in the search results
    search_fields = {
      path  = false,
      date  = true,
      time  = false,
      sig   = false,
      title = true,
      tags  = true,
      ext   = false,
    },
    -- This recombines the chopped up filename from ./scripts/search_files.sh. The output needs to be piped to xargs bat or xargs cat.
    preview = [[date={2};time={3};  datetime=$(echo ${date}T${time} | tr -d '\-:'); \
      sig={4};   sig=$(echo   $sig   | tr -d '.' | tr " " "="); if [ ! -z ${sig} ]   ; then sig="==${sig}";     fi; \
      title={5}; title=$(echo $title | tr -d '.' | tr ' ' '-'); if [ ! -z ${title} ] ; then title="--${title}"; fi; \
      tags={6};  tags=$(echo  $tags  | tr -d '.' | tr ' ' '_'); if [ ! -z ${tags} ]  ; then tags="__${tags}";   fi; \
      ext={7}; \
      echo {1}${datetime}${sig}${title}${tags}${ext} | ]],
  },
  -- Options for ripgrep (Only relevant for contents search)
  rg = {
    opts = "--column --color=always",
    fzf = {
      opts = {
        ['--reverse'] = true,
        ['--no-info'] = true,
        ['--no-separator'] = true,
        ['--no-hscroll'] = true,
        ['--preview-window'] = 'bottom:50%',
        ['-i'] = true,
      },
      -- Checks if $line=$file in case rg --files is used and doesn't return a line number
      -- This currently does nothing until I figure out if there's a good way to chop up filenames in the rg search
      preview = "file=$(echo {} | cut -d ':' -f1); \
        line=$(echo {} | cut -d ':' -f2); \
        if [ \"$line\" = \"$file\" ] ; then line=0; fi;",
    },
  },
}

M.options = M.defaults

return M
