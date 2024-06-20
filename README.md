# denote-fzf-lua

Neovim plugin that uses [`fzf-lua`](https://github.com/ibhagwan/fzf-lua) to search a directory of notes formatted with the [Emacs Denote package's file-naming scheme](https://protesilaos.com/emacs/denote#h:4e9c7512-84dc-4dfb-9fa9-e15d51178e5d):

`DATE==SIGNATURE--TITLE__KEYWORDS.EXTENSION`

The nice custom table for Denote files is the only unique feature of this plugin. If you don't care about that you should just configure `fzf-lua` alone however you like it.

![](https://i.imgur.com/1lTDhOz.png)

# Installation / Config

Example config via [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "DefaultGen/denote-fzf-lua",
  opts = {
    dir = "~/notes" -- Denote notes directory

    -- Toggle which Denote fields are displayed in search
    search_fields = {
      path      = false,
      date      = true,
      time      = false,
      sig       = false,
      title     = true,
      keywords  = true,
      ext       = false,
    },

    -- OPTIONAL:
    -- fzf-lua plugin options. Check fzf-lua docs for full details.
    -- Use this to set custom window and fzf options (and more)
    fzf_lua_opts = {
      winopts = {
        height = 0.85,
        width  = 0.80,
        row    = 0.35,
        col    = 0.50,
        preview = {
          layout = 'vertical',   -- vertical, horizontal, or flex
          vertical = 'down:45%', -- Alt: horizontal = 'right:50%'
        },
      },
      -- Options sent to fzf. If you don't include these, it will be
      -- set to the defaults below (which look like the screenshot)
      fzf_opts = {
        ['--reverse'] = true,
        ['--no-info'] = true,
        ['--no-separator'] = true,
        ['--no-hscroll'] = true,
        ['-i'] = true,
      },
    },
  },
},
```

## Dependencies

* [`ibhagwan/fzf-lua`](https://github.com/ibhagwan/fzf-lua) - Neovim plugin
* `fzf` - Fuzzy finder
* (OPTIONAL) `fd` - Fast `find` replacement
* (OPTIONAL) `sd` - Fast `sed` replacement
* (OPTIONAL) [`qsv`](https://github.com/jqnatividad/qsv)- Fast `column` replacement
* (OPTIONAL) `bat` - Nicer preview than `cat`
* (OPTIONAL) `ripgrep` - Required to search note contents

```
Arch Linux: sudo pacman -S fzf ripgrep fd sd bat
            yay -S qsv-bin

Debian: sudo apt install fzf ripgrep fd-find sd bat
        export PATH=/usr/lib/cargo/bin/:$PATH (to add `fd` to path)
        Install qsv from Github
```

If the optional dependencies are missing `denote-fzf-lua` falls back to standard Unix tools. The Rust tools are 2-3x faster. On my PC this is a difference of 0.1s vs 0.2s for 10k notes, or 0.6s vs 1.9s for 100k notes.

`qsv` is used over the smaller, more ubiquitous `xsv` because it can table format very large inputs (e.g. 100k notes) without errors.

# :DenoteSearch command

```vim
" Searches filenames in `dir` with fzf and displays results as a table
:DenoteSearch files

" Standard rg search through file contents in `dir`.
" Nothing special about this, it's just a convenient command that uses the same fzf-lua options
:DenoteSearch contents
```

# License

GNU AGPL (`fzf-lua` license)
