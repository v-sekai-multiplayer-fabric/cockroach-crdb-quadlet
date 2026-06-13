# cockroach-crdb-quadlet

Podman [quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
source for a single-node CockroachDB (mTLS) service, run by systemd on
an AlmaLinux host (e.g. one provisioned from `linux-base-image`).

This repo is the source of truth for the unit; it is installed onto a
host rather than baked into a VM image.

## Layout

- `quadlets/cockroachdb.container` — the quadlet. systemd's podman
  generator turns it into `cockroachdb.service` at boot. Image tag is
  pinned here; bumping it is a deliberate edit to this repo.
- `install.sh` — installs the unit to `/etc/containers/systemd/`,
  creates `/var/lib/cockroach` (data) and `/etc/cockroach/certs`
  (mTLS PKI mountpoint), pre-pulls the pinned image, reloads systemd.

## Install

```sh
sudo ./install.sh            # installs unit + pre-pulls the image
sudo systemctl start cockroachdb.service
```

`PULL=0 sudo -E ./install.sh` skips the pre-pull (the service pulls on
first start instead).

## Configuration (per-deployment, NOT in this repo)

- `/var/lib/cockroach` — bind-mount durable storage here.
- `/etc/cockroach/certs` — the mTLS PKI, delivered per deployment.

## CI

`.github/workflows/lint.yml` runs the units through podman's systemd
generator in dry-run mode on every push/PR, so a malformed unit fails CI.
