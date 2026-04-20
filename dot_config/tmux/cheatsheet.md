# tmux cheatsheet · prefix: Ctrl+Space

## Sessions
| Command | Action |
|---------|--------|
| `tt` | connect to totoro session |
| `tw` / `twork` | connect to nordhealth session |
| `ts` | fuzzy pick / launch session |
| `tl` | list sessions |
| `tn <name>` | new named session |
| `tk` | kill session (fuzzy pick) |
| `prefix d` | detach (session keeps running) |
| `ta` | attach to session (fuzzy pick) |
| `prefix s` | sesh session picker popup |

## Windows
| Key | Action |
|-----|--------|
| `prefix c` | new window (same path) |
| `Alt+1`–`9` | switch to window (no prefix) |
| `Alt+n` / `Alt+p` | next / previous window |
| `Alt+Shift+←` / `Alt+Shift+→` | previous / next window |
| `Alt+[` / `Alt+]` | previous / next window |
| `Alt+Tab` | last used window |
| `prefix ,` | rename window |
| `prefix &` | kill window |

## Panes
| Key | Action |
|-----|--------|
| `prefix \` | split right |
| `prefix -` | split down |
| `Alt+hjkl` | navigate panes (no prefix) |
| `Alt+↑` / `Alt+↓` | cycle panes by index |
| `prefix ←→↑↓` | navigate panes |
| `prefix z` | zoom pane fullscreen (toggle) |
| `prefix x` | kill pane |

## Copy / Extract
| Key | Action |
|-----|--------|
| `prefix [` | enter copy mode (q to exit) |
| `v` (in copy mode) | begin selection |
| `y` (in copy mode) | yank selection (keeps highlight) |
| mouse drag | select + copy to clipboard |
| `o` (in copy mode) | open URL/file under cursor |
| `prefix Tab` | extrakto: fuzzy-pick tokens from screen |

## Other
| Key | Action |
|-----|--------|
| `prefix H` | show this cheatsheet |
| `prefix r` | reload config |
