# AGENTS.md

## Purpose

This repository contains Ansible playbooks and roles for deploying services to
Raspberry Pi and Unraid hosts. Treat changes as infrastructure changes: preserve
idempotency, keep host-specific data out of version control, and validate before
running anything against a real machine.

## Repository map

- Top-level `*.yml` and `*.yaml` files are playbooks. `unraid.yml`, `pihole.yml`,
  `rutorrent.yml`, and `raspi-bootstrap.yml` are the main entry points.
- `roles/<role>/defaults/main.yml` contains overridable role defaults.
- `roles/<role>/tasks/main.yml` is the role entry point. Larger roles import
  focused task files such as `facts.yml` or `backup.yml`.
- `roles/<role>/templates/` contains Jinja templates, primarily Docker Compose
  files and service configuration.
- `roles/<role>/files/` contains static files copied to managed hosts.
- `roles/common/handlers/main.yml` contains shared handlers.
- `inventories/example/` documents the expected inventory layout and variable
  names. The real `inventories/production/` directory is intentionally ignored.
- `devenv.nix` is the primary development environment definition; `flake.nix`
  provides a smaller Ansible-only Nix shell.

## Development environment

Prefer the checked-in environment so validation uses the project's pinned
tooling:

```sh
devenv shell
```

Ansible and `ansible-lint` are the important tools.
In restricted environments where Ansible cannot write below
the home directory, prefix validation commands with:

```sh
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local
```

Do not run `devenv test`, `deployunraid`, or an unqualified `ansible-playbook`
command as routine validation: they connect to the production inventory.

## Change conventions

- Use fully qualified Ansible module names, for example
  `ansible.builtin.template` and `community.docker.docker_compose_v2`.
- Give tasks descriptive `name` values. Imported task files may begin with an
  unnamed `ansible.builtin.import_tasks`, matching existing roles.
- Put reusable, non-secret values in role defaults. Put environment- and
  host-specific values in inventory group or host vars.
- Match established variable prefixes for service-specific settings (for
  example `pihole_`, `torrent_vpn_`, or `nzbschedule_`). Shared Docker paths and
  identity values use the existing `docker_*` variables.
- Quote file modes (`"0644"`, `"0755"`) and values that YAML might coerce, such
  as cron expressions, ports used as strings, and version-like values.
- Set explicit owner, group, and mode on managed files and directories whenever
  the target platform supports them.
- Register a task result only when later tasks, handlers, or diagnostics use it.
- Commands and shell tasks must state their change behavior. Prefer an Ansible
  module over `command` or `shell`; if a read-only command is necessary, use
  `changed_when: false`. Use `shell` only for shell features such as pipes.
- Preserve check-mode behavior. Fact-discovery tasks in `facts.yml` commonly use
  `check_mode: false` and `changed_when: false` so later templates can still be
  evaluated during `--check`.
- Keep templates declarative and derive their values from variables. Follow the
  neighboring role's Docker Compose labels, network, path, and user conventions
  when adding another containerized service.
- Add a role to a playbook only after its defaults, tasks, and templates are in
  place. Add a tag when the surrounding playbook uses role-level tags.
- Keep edits focused. Do not reformat unrelated YAML or modernize neighboring
  roles as part of a small service change.

## Secrets and inventories

- Never commit `inventories/production/`, private keys, API keys, VPN
  credentials, passwords, repository keys, or rendered environment files.
- Values in `inventories/example/` must be obviously fake placeholders. When a
  change introduces a required variable, document it there with a safe dummy
  value.
- Do not print production variables or rendered secret-bearing templates during
  diagnostics. Use Ansible Vault or another external secret mechanism if secret
  material ever needs to be versioned.
- Image tags are currently often configurable and may default to `latest`.
  Preserve that behavior unless the task explicitly calls for version pinning.

## Validation

Start with checks that do not contact managed hosts. Use the example inventory
and limit checks to the playbooks affected by the change:

```sh
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ansible-playbook \
  --inventory inventories/example/hosts --syntax-check pihole.yml
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ansible-lint path/to/changed/file.yml
```

`raspi-bootstrap.yml` requires a target even for a syntax check; supply a safe
example host with `--extra-vars target=raspberrypi1`. Warnings about unmatched
`unraid` or `hasatellite` groups are expected with the current example inventory.

For an inventory-aware dry run, use `--check --diff` only when the target and
inventory are explicitly known and approved:

```sh
ansible-playbook --inventory inventories/production <playbook>.yml \
  --limit <host> --check --diff
```

Some tasks deliberately run in check mode to discover remote facts, so even a
dry run may connect to hosts and execute read-only commands. Docker image pulls,
container recreation, pruning, reboots, networking, DNS, and SSH changes are
especially operationally sensitive. Never perform a live deployment unless the
user explicitly requests it and identifies the intended inventory or host.

When changing shell scripts in `roles/mediasync/files/`, also run a non-executing
syntax check on each changed script:

```sh
bash -n roles/mediasync/files/<script>.sh
```

Report which checks ran and distinguish new failures from pre-existing lint or
inventory issues.

## Role implementation checklist

When adding or extending a role:

1. Define safe defaults in `roles/<role>/defaults/main.yml` where appropriate.
2. Gather reusable remote IDs or platform facts in `tasks/facts.yml` if needed.
3. Create required directories before templating or copying files.
4. Render configuration with explicit permissions.
5. Use handlers for restarts when practical; avoid unconditional disruption.
6. Ensure a second run is idempotent and that `--check` remains meaningful.
7. Update `inventories/example/` for new required deployment variables.
8. Run syntax checks and scoped linting, then document any validation that
   requires real infrastructure and was not performed.

## Operational boundaries

The playbooks administer real network services and can affect DNS, SSH access,
storage, backups, containers, and host availability. Inspect the selected
playbook, its role order, the effective inventory, and any `--limit` before a
deployment. Do not assume a host name, IP address, production path, credential,
or desired destructive action. In particular, do not prune Docker resources,
restore backups, alter shares, or reboot hosts outside an explicitly requested
deployment scope.
