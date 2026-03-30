package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Colors
var (
	cyan   = lipgloss.Color("#00d7ff")
	green  = lipgloss.Color("#5af78e")
	yellow = lipgloss.Color("#f4f99d")
	dim    = lipgloss.Color("#666666")
	white  = lipgloss.Color("#ffffff")
)

// Styles
var (
	headerStyle    = lipgloss.NewStyle().Foreground(cyan).Bold(true)
	sectionStyle   = lipgloss.NewStyle().Foreground(cyan).Bold(true)
	selectedStyle  = lipgloss.NewStyle().Foreground(cyan).Bold(true)
	normalStyle    = lipgloss.NewStyle().Foreground(white)
	descStyle      = lipgloss.NewStyle().Foreground(dim)
	cleanStyle     = lipgloss.NewStyle().Foreground(green)
	dirtyStyle     = lipgloss.NewStyle().Foreground(yellow)
	filterStyle    = lipgloss.NewStyle().Foreground(cyan)
	footerStyle    = lipgloss.NewStyle().Foreground(dim)
	separatorStyle = lipgloss.NewStyle().Foreground(dim)
)

type Item struct {
	Section string
	Name    string
	Desc    string
	Command []string
}

type HeaderInfo struct {
	Branch   string
	Clean    bool
	Pending  int
	Hostname string
	OS       string
}

type Model struct {
	items      []Item
	cursor     int
	filter     string
	filtered   []Item
	header     HeaderInfo
	termWidth  int
	termHeight int
	quitting   bool
}

type tickMsg struct{}

func sourceDir() string {
	if d := os.Getenv("CHEZMOI_SOURCE_DIR"); d != "" {
		return d
	}
	home, _ := os.UserHomeDir()
	return filepath.Join(home, "dotfiles")
}

func refreshHeader() HeaderInfo {
	dir := sourceDir()
	info := HeaderInfo{
		OS: runtime.GOOS,
	}
	info.Hostname, _ = os.Hostname()

	if out, err := exec.Command("git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD").Output(); err == nil {
		info.Branch = strings.TrimSpace(string(out))
	}

	if out, err := exec.Command("git", "-C", dir, "status", "--porcelain").Output(); err == nil {
		info.Clean = len(strings.TrimSpace(string(out))) == 0
	}

	if out, err := exec.Command("bash", "-c", "chezmoi diff --no-pager 2>/dev/null | grep '^diff' | wc -l").Output(); err == nil {
		n := strings.TrimSpace(string(out))
		fmt.Sscanf(n, "%d", &info.Pending)
	}

	return info
}

func dotfilesItems() []Item {
	cmds := []struct{ name, desc string }{
		{"sync", "pull + apply"},
		{"push", "commit + push"},
		{"apply", "apply configs"},
		{"diff", "show pending changes"},
		{"status", "machine info"},
		{"theme", "switch starship theme"},
		{"secrets", "inject secrets"},
		{"rollback", "restore a snapshot"},
		{"aliases", "show active aliases"},
		{"utils", "list utility scripts"},
		{"info", "active aliases and tools"},
		{"doctor", "chezmoi diagnostics"},
	}
	items := make([]Item, len(cmds))
	for i, c := range cmds {
		items[i] = Item{
			Section: "DOTFILES",
			Name:    c.name,
			Desc:    c.desc,
			Command: []string{"dotfiles", c.name},
		}
	}
	return items
}

func utilsItems() []Item {
	home, _ := os.UserHomeDir()
	binDir := filepath.Join(home, ".local", "bin")
	entries, err := os.ReadDir(binDir)
	if err != nil {
		return nil
	}

	skip := map[string]bool{"dotfiles": true, "dotfiles-dashboard": true}
	var items []Item
	for _, e := range entries {
		if e.IsDir() || skip[e.Name()] {
			continue
		}
		fi, err := e.Info()
		if err != nil || fi.Mode()&0111 == 0 {
			continue
		}
		items = append(items, Item{
			Section: "UTILS",
			Name:    e.Name(),
			Command: []string{filepath.Join(binDir, e.Name())},
		})
	}
	return items
}

func applyFilter(items []Item, filter string) []Item {
	if filter == "" {
		return items
	}
	f := strings.ToLower(filter)
	var out []Item
	for _, it := range items {
		text := strings.ToLower(it.Name + " " + it.Desc)
		if strings.Contains(text, f) {
			out = append(out, it)
		}
	}
	return out
}

func initialModel() Model {
	var all []Item
	all = append(all, dotfilesItems()...)
	all = append(all, utilsItems()...)

	m := Model{
		items:    all,
		filtered: all,
		header:   refreshHeader(),
	}
	return m
}

func (m Model) Init() tea.Cmd {
	return tea.Tick(5*time.Second, func(t time.Time) tea.Msg {
		return tickMsg{}
	})
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.termWidth = msg.Width
		m.termHeight = msg.Height

	case tickMsg:
		m.header = refreshHeader()
		return m, tea.Tick(5*time.Second, func(t time.Time) tea.Msg {
			return tickMsg{}
		})

	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyCtrlC:
			m.quitting = true
			return m, tea.Quit

		case tea.KeyUp:
			if m.cursor > 0 {
				m.cursor--
			}

		case tea.KeyDown:
			if m.cursor < len(m.filtered)-1 {
				m.cursor++
			}

		case tea.KeyEnter:
			if len(m.filtered) > 0 && m.cursor < len(m.filtered) {
				it := m.filtered[m.cursor]
				c := exec.Command(it.Command[0], it.Command[1:]...)
				return m, tea.ExecProcess(c, func(err error) tea.Msg {
					return tickMsg{}
				})
			}

		case tea.KeyBackspace:
			if len(m.filter) > 0 {
				m.filter = m.filter[:len(m.filter)-1]
				m.filtered = applyFilter(m.items, m.filter)
				if m.cursor >= len(m.filtered) {
					m.cursor = max(0, len(m.filtered)-1)
				}
			}

		case tea.KeyRunes:
			s := string(msg.Runes)
			if s == "q" && m.filter == "" {
				m.quitting = true
				return m, tea.Quit
			}
			m.filter += s
			m.filtered = applyFilter(m.items, m.filter)
			if m.cursor >= len(m.filtered) {
				m.cursor = max(0, len(m.filtered)-1)
			}
		}
	}

	return m, nil
}

func (m Model) View() string {
	if m.quitting {
		return ""
	}

	var b strings.Builder
	w := m.termWidth
	if w == 0 {
		w = 80
	}

	// Header
	branchStatus := headerStyle.Render("dotfiles")
	branchStatus += " — " + headerStyle.Render(m.header.Branch)
	if m.header.Clean {
		branchStatus += " " + cleanStyle.Render("✓")
	} else {
		branchStatus += " " + dirtyStyle.Render("●")
	}

	pendingStr := fmt.Sprintf("chezmoi: %d pending", m.header.Pending)
	if m.header.Pending == 0 {
		branchStatus += "  |  " + cleanStyle.Render(pendingStr)
	} else {
		branchStatus += "  |  " + dirtyStyle.Render(pendingStr)
	}

	branchStatus += "  |  " + descStyle.Render(m.header.Hostname+"  "+m.header.OS)
	b.WriteString(branchStatus + "\n")
	b.WriteString(separatorStyle.Render(strings.Repeat("─", w)) + "\n\n")

	// Render items grouped by section
	idx := 0
	currentSection := ""
	for _, it := range m.filtered {
		if it.Section != currentSection {
			if currentSection != "" {
				b.WriteString("\n")
			}
			currentSection = it.Section
			b.WriteString(sectionStyle.Render(currentSection) + "\n")
		}

		cursor := "  "
		if idx == m.cursor {
			cursor = "> "
		}

		name := it.Name
		if idx == m.cursor {
			name = selectedStyle.Render(name)
		} else {
			name = normalStyle.Render(name)
		}

		line := cursor + name
		if it.Desc != "" {
			padding := 16 - len(it.Name)
			if padding < 2 {
				padding = 2
			}
			line += strings.Repeat(" ", padding) + descStyle.Render(it.Desc)
		}
		b.WriteString(line + "\n")
		idx++
	}

	// Filter line
	b.WriteString("\n")
	if m.filter != "" {
		b.WriteString(filterStyle.Render("[filter: "+m.filter+"]") + "\n")
	} else {
		b.WriteString(descStyle.Render("[type to filter]") + "\n")
	}

	// Footer
	b.WriteString(footerStyle.Render("q quit    enter launch    ↑↓ navigate") + "\n")

	return b.String()
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
