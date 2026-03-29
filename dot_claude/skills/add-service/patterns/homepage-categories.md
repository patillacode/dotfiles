# Homepage Categories and Entry Formats

Live file: `/home/dvitto/services/homepage/config/services.yaml`

---

## Tab Structure

### TAB: MEDIA
- **Media Center** — streaming and consumption (plex, immich, overseerr, tautulli, dispatcharr)
- **Media Management** — *arr suite automation (radarr, sonarr, prowlarr, bazarr, huntarr, cleanuparr, jackett)
- **Downloads** — download clients (transmission, sabnzbd)

### TAB: PROJECTS
- **Production Sites** — live production deployments (ligaconquistador, humedecete)
- **Personal Projects** — personal apps and games (binnacle, kuevasonne, pimpositor, patilloid, exex, visit-book)

### TAB: TOOLS
- **Productivity** — tools for personal use (nextcloud, atuin, docmost, excalidraw, vikunja)
- **Infrastructure** — server/ops tools (glances, beszel, dozzle, arcane, wud, teamspeak, Nginx Proxy Manager)

### Always visible (all tabs)
- **system** — glances CPU/temp/network/mem/process widgets
- **storage** — glances filesystem widgets

---

## YAML Indentation Rules

The file uses a specific indentation pattern — **follow it exactly**:

```yaml
- Category Name:        # 0 indent, list item
      - service-name:   # 6 spaces indent (4 + 2 for the dash)
            key: value  # 12 spaces indent
```

This is non-standard YAML (6-space indent for service entries, 12-space for properties) but is what the existing file uses throughout. Match it exactly.

---

## Entry Formats

### Without widget (most tools)

```yaml
      - <service>:
            icon: <service>.png
            href: https://<service>.patilla.es
            description: Short description of the service
            server: my-docker
            container: <container-name>
            showStats: true
```

### Without widget, internal access only (no public domain)

```yaml
      - <service>:
            icon: <service>.png
            href: http://192.168.1.2:<port>
            description: Short description of the service
            server: my-docker
            container: <container-name>
            showStats: true
```

### With widget + API key

```yaml
      - <service>:
            icon: <service>.png
            href: https://<service>.patilla.es
            description: Short description of the service
            server: my-docker
            container: <container-name>
            showStats: true
            widget:
                type: <widget-type>
                url: http://192.168.1.2:<port>
                key: {{HOMEPAGE_VAR_<SERVICE>_KEY}}
```

Widget URL always uses the internal IP `192.168.1.2:<port>`, not the public domain. The `key` references a var from homepage's `.env` file at `/home/dvitto/services/homepage/.env`.

### With widget + credentials (not key)

```yaml
      - <service>:
            icon: <service>.png
            href: https://<service>.patilla.es
            description: Short description of the service
            server: my-docker
            container: <container-name>
            showStats: true
            widget:
                type: <widget-type>
                url: http://192.168.1.2:<port>
                username: {{HOMEPAGE_VAR_<SERVICE>_USER}}
                password: {{HOMEPAGE_VAR_<SERVICE>_PASS}}
```

### With ping check (for remote/external services)

```yaml
      - <service>:
            icon: <service>.png
            href: https://<service>.patilla.es
            description: Short description of the service
            server: my-docker
            container: <container-name>
            ping: 192.168.1.2
            showStats: true
```

---

## Icon Conventions

Prefer in this order:

1. **`<service>.png`** — Homepage built-in icon (most common services have one)
   - Check: https://github.com/walkxcode/dashboard-icons
   - Examples: `plex.png`, `nextcloud.png`, `radarr.png`, `vikunja.png`

2. **`si-<service>.svg-#RRGGBB`** — Simple Icons with brand color
   - Examples: `si-excalidraw.svg-#6965DB`, `si-docker.svg-#2496ED`

3. **`mdi-<icon-name>.svg-#RRGGBB`** — Material Design Icons
   - Examples: `mdi-server-outline.svg-#F1C9AF`

4. **Full URL** — for services without standard icons
   - Examples: custom logos at their own domain, DuckDuckGo image proxy

---

## Inserting New Entries

Use **targeted `Edit`** to insert entries. Never rewrite the entire services.yaml.

Find the end of the target category by identifying the last entry, then insert after it. For example, to add to "Productivity":

Find the last entry in Productivity (currently `vikunja`), and insert after its closing lines before the `- Infrastructure:` line.

**Always verify the indentation matches** surrounding entries before writing. The file is indentation-sensitive YAML.

---

## API Key Setup (if widget needs one)

After adding an entry with `{{HOMEPAGE_VAR_<SERVICE>_KEY}}`:

1. Get the API key from the service's settings UI
2. Add to `/home/dvitto/services/homepage/.env`:
   ```
   HOMEPAGE_VAR_<SERVICE>_KEY=<api-key-value>
   ```
3. Restart homepage: `cd /home/dvitto/services/homepage && just restart`

Include this as a manual step in the Phase 4 summary.
