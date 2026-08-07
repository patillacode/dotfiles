# herdr cheatsheet · prefix: Ctrl+Space

Mouse-first, agent-aware multiplexer. **tmux is fully retired** (removed from the
dotfiles + all machines as of July 2026) — herdr is the multiplexer now. `prefix ?`
shows every live binding inside herdr. The "Coming from tmux" map below is kept as a
migration reference.

## Concepts
| Term | What it is |
|------|------------|
| session | Persistent background server. `herdr` attaches the default one. |
| workspace | Project container (one per repo/task). Owns tabs + panes. |
| tab | A layout inside a workspace (e.g. agents / logs / server). |
| pane | A real terminal. Splittable. Survives detach. |
| agent | A process herdr recognizes: `working` `blocked` `done` `idle`. |

## Getting started
| Command | Action |
|---------|--------|
| `h` | launch / attach herdr (alias for `herdr`) |
| `hs` | fuzzy machine picker (local or `--remote`) |
| `ht` | attach remote totoro |
| `hch` | show this cheatsheet |
| `herdr integration install claude` | authoritative agent-state detection |
| `herdr agent list` | what herdr currently sees |
| `herdr agent explain <target> --json` | why a pane got its state |
| `herdr server stop` | stop everything |
| `herdr update` | update herdr |

`HERDR_ENV=1` means you're already inside a herdr pane — don't launch a nested one.

## Mouse (learn this first)
| Action | Result |
|--------|--------|
| click pane / tab | focus it |
| drag split border | resize |
| right-click | pane / tab menu |
| drag-select | select + copy (copy_on_select is on) |
| double-click | copy word |

## Workspaces
| Key | Action |
|-----|--------|
| `prefix w` | workspace picker |
| `prefix [` / `prefix ]` | previous / next workspace |
| `prefix g` | session navigator |
| `prefix Shift+n` | new workspace |
| `prefix Shift+w` | rename workspace |
| `prefix Shift+d` | close workspace |
| `prefix a` | toggle last two spaces (MRU) |
| `prefix Shift+1`–`9` | jump to space N |

## Tabs
| Key | Action |
|-----|--------|
| `prefix c` | new tab |
| `prefix n` / `prefix p` | next / previous tab |
| `prefix 1`–`9` | switch to tab |
| `prefix Shift+t` | rename tab |

## Panes
| Key | Action |
|-----|--------|
| `prefix \` | split right (side by side) |
| `prefix -` | split down (stacked) |
| `prefix hjkl` | focus pane (also `prefix ←↓↑→`) |
| `prefix z` | zoom pane fullscreen (toggle) |
| `prefix x` | close pane |
| `prefix e` | open pane scrollback in $EDITOR |

## Session
| Key | Action |
|-----|--------|
| `prefix q` | detach (everything keeps running) |
| `prefix s` | settings |
| `prefix ?` | keybinding help (live) |
| `prefix Shift+r` | reload config |

Detach and reattach: `prefix q`, later `h`. Panes and agents survive.

## Coming from tmux
| tmux | herdr | notes |
|------|-------|-------|
| `C-Space` prefix | `C-Space` prefix | same, on purpose |
| `\` / `-` splits | `\` / `-` splits | same |
| `Alt+hjkl` nav | `prefix hjkl` | herdr nav is prefixed |
| windows | tabs + workspaces | workspace ≈ a whole tmux session per repo |
| sesh picker | `prefix w` / `hs` | workspaces auto-create per cwd |
| session last-window | `prefix a` | no native equivalent, and alt+tab doesn't reach herdr here; `herdr-last-space` script |
| resurrect / continuum | server + `pane_history` | persists without plugins |
| extrakto | — | **no equivalent** (use mouse copy) |
| tmux-yank / tmux-open | mouse copy / click | **no plugin needed** |
| status bar plugins | agent sidebar | states roll up per workspace |

The sidebar is the point: across all workspaces you see which agent is `working`,
which is `blocked` waiting on you, which is `done`.

## Exercises (do these over a few days)
1. `cd` a repo, run `h`, start `claude` in the pane — watch the sidebar state change.
2. Split panes with the mouse (drag border), then with `prefix \` and `prefix -`.
3. Open a second repo in a new workspace (`prefix Shift+n`); read the rolled-up
   agent state per workspace in the sidebar.
4. Detach with `prefix q`, close the terminal, reopen, run `h` — confirm panes and
   the running agent survived.
5. Run agents in two workspaces at once; use the sidebar to spot `blocked` vs
   `working` without switching to each.
6. `herdr agent explain <target> --json` on a mislabeled pane to see the detector's
   reasoning. Bonus: `ht` / `hs` to drive herdr on totoro over SSH.

## Verdict checklist (vs tmux)
- [ ] Persistence: does detach/reattach feel as solid as resurrect/continuum?
- [ ] Agent visibility: does the sidebar save you real context-switching?
- [ ] Friction: how often does muscle memory misfire after a week?
- [ ] Remote: is `herdr --remote` better/worse than SSH + tmux?
- [ ] Losses: do you actually miss sesh, extrakto, or the status bar?
