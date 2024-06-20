# denote-fzf-lua

Neovim plugin that uses `fzf-lua` to search a directory of notes formatted with the Emacs Denote file-naming scheme:

`DATE==SIGNATURE--TITLE__KEYWORDS.EXTENSION`

The nice custom table for Denote files is the only unique 'feature' of this plugin. If you don't care about that you should just use `fzf-lua` on its own.

## Dependencies

* `fzf`            - Fuzzy finder
* `ripgrep`        - Fast `grep` replacement
* `fd`  (OPTIONAL) - Fast `find` replacement
* `sd`  (OPTIONAL) - Fast `sed` replacement
* `qsv` (OPTIONAL) - Fast `column` replacement

```
Arch Linux: sudo pacman -S fzf ripgrep fd sd
            yay -S qsv-bin

Debian: sudo apt install fzf ripgrep fd sd

qsv is available here: https://github.com/jqnatividad/qsv
```

If the optional dependencies are missing `denote-fzf-lua` falls back to standard Unix tools.

As a rough benchmark, the Rust tools can perform a search through 10k notes in 0.1s vs. 0.2s for standard tools on my PC. For 100k notes it's 0.6s vs. 2.1s.

`qsv` is used over the smaller, more ubiquitous `xsv` because it can table format very large inputs (e.g. 100k notes) without errors.

# License

GNU AGPL (`fzf-lua` license)
