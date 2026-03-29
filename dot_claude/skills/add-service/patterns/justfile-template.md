# Justfile Templates

**Do not deviate from these templates.** The root justfile and service.just are fixed contracts. Only cli.just varies per service.

---

## Root `justfile` — without cli.just

Use for services that have no meaningful CLI:

```justfile
set dotenv-load
set shell := ["bash", "-cu"]

import 'just/service.just'
# import 'just/cli.just'

# Show available recipes
default:
    @just --list
```

---

## Root `justfile` — with cli.just

Use when the service has a CLI worth wrapping (uncomment the import):

```justfile
set dotenv-load
set shell := ["bash", "-cu"]

import 'just/service.just'
import 'just/cli.just'

# Show available recipes
default:
    @just --list
```

---

## `just/service.just` — fixed, always exactly this

```justfile
# Start services
[group('service')]
up:
    docker compose up -d

# Stop services
[group('service')]
down:
    docker compose down

# Restart services
[group('service')]
restart:
    docker compose restart

# Pull latest images and recreate containers
[group('service')]
update:
    docker compose pull && docker compose up -d

# Follow container logs (optionally pass a service name)
[group('service')]
logs *args:
    docker compose logs -f {{args}}
```

All five recipes are always present. Do not add, remove, or rename them. Do not change the group names.

---

## `just/cli.just` — skeleton (adapt per service)

Only create this file if the service has a meaningful CLI. Base it on the vikunja pattern:

```justfile
# --- <ServiceName> CLI ---

container := "<service>"
bin := "/path/to/binary/inside/container"

# Run any <service> command directly
[group('cli')]
run *args:
    docker exec {{container}} {{bin}} {{args}}

# <describe what this does>
[group('cli')]
<recipe-name> *args:
    docker exec {{container}} {{bin}} <subcommand> {{args}}
```

**When to create cli.just:**
- Service has a documented CLI tool inside the container (e.g. vikunja, gitea, forgejo)
- Service has admin/maintenance commands worth surfacing (migrations, user management, dumps)
- Do NOT create just for `docker exec <container> sh` access — that's not worth wrapping

**When NOT to create cli.just:**
- Static file servers, simple web UIs, proxies
- Services that are fully configured via environment variables
- Services where all operations happen through the web UI

---

## Reference

The canonical implementation is at `/home/dvitto/services/vikunja/`:
- `justfile` — root with both imports
- `just/service.just` — exact 5-recipe baseline
- `just/cli.just` — full CLI wrapper with multiple grouped recipes
