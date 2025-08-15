# CLI Cheat Sheet

Quick reference for some of the installed tools and aliases.

## Navigation

```bash
z foo         # jump to directory containing 'foo' using zoxide
ls            # mapped to exa --icons
cat file      # uses bat for syntax highlighting
rg pattern    # fast search for 'pattern'
fd name       # find files or directories named 'name'
```

## tmux

```bash
tmux new -s session   # create new tmux session
Ctrl-b d              # detach session
Ctrl-b "              # split window horizontally
Ctrl-b %              # split window vertically
```

## fzf

```bash
ctrl-r       # search shell history
fzf          # fuzzy-find files
```

## entr

```bash
ls *.md | entr make   # run make whenever a markdown file changes
```

For more examples, check the official documentation linked in `command_reference.md`.
