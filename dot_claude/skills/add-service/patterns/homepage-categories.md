# Homepage Groups and Docker Label Formats

---

## Tab → Group Structure

```
Media tab:          Media Center, Music, Media Management, Downloads
Apps tab:           Apps
Misc tab:           Personal Projects, Production Sites
Dev tab:            Dev
Monitoring tab:     Monitoring
Infrastructure tab: Infrastructure
```

### Group reference (example services for placement guidance)

| Group | Tab | Examples |
|-------|-----|---------|
| Media Center | Media | plex, immich, seerr/overseerr, tautulli, dispatcharr |
| Music | Media | navidrome, lidarr, slskd, icecast |
| Media Management | Media | radarr, sonarr, prowlarr, bazarr, jackett, cleanuparr, maintainerr |
| Downloads | Media | transmission, sabnzbd |
| Apps | Apps | nextcloud, docmost, vikunja, freshrss, ironcalc, zipline, excalidraw, lasso, atuin, secretapi |
| Personal Projects | Misc | visit-book, binnacle*, kuevasonne*, pimpositor*, patilloid*, exex |
| Production Sites | Misc | liga conquistador x2, humedecete, madridcam |
| Dev | Dev | forgejo |
| Monitoring | Monitoring | uptime-kuma, checkmate, adguard, glances, beszel, dozzle, kula, cup |
| Infrastructure | Infrastructure | arcane, Nginx Proxy Manager, wireguard, ntfy, syncthing, teamspeak |

\* static sites with no compose file — kept in `services.yaml`

**Always visible (all tabs):** `system` and `storage` (glances widgets, defined in `services.yaml`)

---

## Docker Label Formats

Homepage service discovery reads `homepage.*` labels directly from Docker containers. Add these to the app container's `labels:` block in `compose.yml` — no `services.yaml` edit needed.

### Without widget

```yaml
      - "homepage.group=<Group Name>"
      - "homepage.name=<Display Name>"
      - "homepage.icon=<service>.png"
      - "homepage.href=https://<service>.patilla.es"
      - "homepage.description=<short description>"
      - "homepage.server=my-docker"
      - "homepage.container=<container-name>"
      - "homepage.showStats=true"
```

### With widget + API key

```yaml
      - "homepage.group=<Group Name>"
      - "homepage.name=<Display Name>"
      - "homepage.icon=<service>.png"
      - "homepage.href=https://<service>.patilla.es"
      - "homepage.description=<short description>"
      - "homepage.server=my-docker"
      - "homepage.container=<container-name>"
      - "homepage.showStats=true"
      - "homepage.widget.type=<widget-type>"
      - "homepage.widget.url=http://192.168.1.2:<port>"
      - "homepage.widget.key={{HOMEPAGE_VAR_<SERVICE>_KEY}}"
```

### With widget + credentials

```yaml
      - "homepage.group=<Group Name>"
      - "homepage.name=<Display Name>"
      - "homepage.icon=<service>.png"
      - "homepage.href=https://<service>.patilla.es"
      - "homepage.description=<short description>"
      - "homepage.server=my-docker"
      - "homepage.container=<container-name>"
      - "homepage.showStats=true"
      - "homepage.widget.type=<widget-type>"
      - "homepage.widget.url=http://192.168.1.2:<port>"
      - "homepage.widget.username={{HOMEPAGE_VAR_<SERVICE>_USER}}"
      - "homepage.widget.password={{HOMEPAGE_VAR_<SERVICE>_PASS}}"
```

**Widget URL** always uses the internal IP `http://192.168.1.2:<port>`, never the public domain.

**`HOMEPAGE_VAR_*` variables** resolve from homepage's own `.env` at `/home/dvitto/services/homepage/.env`. Never put them in the service's `.env`.

---

## Fallback: services.yaml (no compose file)

For static sites, external services, or anything without a `compose.yml`, add a YAML entry to `/home/dvitto/services/homepage/config/services.yaml` using the equivalent fields. Use targeted `Edit` — never rewrite the whole file. This is the exception; docker labels are the standard.

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

---

## API Key Setup (if widget needs one)

1. Get the API key from the service's settings UI
2. Add to `/home/dvitto/services/homepage/.env`:
   ```
   HOMEPAGE_VAR_<SERVICE>_KEY=<api-key-value>
   ```
3. Restart homepage: `cd /home/dvitto/services/homepage && just restart`

Include this as a manual step in the Phase 4 summary.
