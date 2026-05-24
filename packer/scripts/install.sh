#!/usr/bin/env bash
# Provisioner: layers CRDB VM bits on top of linux-base-image.
# Runs as root via `sudo -E bash`.
set -euo pipefail

install -d -m 0755 /etc/containers/systemd
install -m 0644 /tmp/quadlets/*.container /etc/containers/systemd/
rm -rf /tmp/quadlets

# Data dir for CRDB. The infra side bind-mounts a Harvester PVC here
# via cloud-init at first boot.
install -d -m 0700 /var/lib/cockroach
# mTLS certs mountpoint; populated by per-VM Secret + cloud-init data source.
install -d -m 0750 /etc/cockroach/certs

# Pre-pull the CRDB image so first boot is fast. Tag pinned here;
# bumping it is a deliberate change to this repo (and re-bake).
podman pull ghcr.io/v-sekai/cockroach:e7195c11905a24a30768c6a9cab39eb571a30d25

dnf clean all
cloud-init clean --logs
: > /etc/machine-id
rm -f /var/lib/dbus/machine-id || true
fstrim -av || true
