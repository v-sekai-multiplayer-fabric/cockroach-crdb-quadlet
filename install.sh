#!/usr/bin/env bash
# Install the CockroachDB podman quadlet onto this host.
#
# Copies the quadlet unit(s) in ./quadlets into the system quadlet
# directory where podman's systemd generator picks them up, creates the
# data + cert mountpoints, optionally pre-pulls the pinned image, and
# reloads systemd so the generated services appear.
#
# Run as root:  sudo ./install.sh
# Skip the pre-pull with:  PULL=0 sudo -E ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
QUADLET_DST=/etc/containers/systemd
PULL="${PULL:-1}"

[ "$(id -u)" -eq 0 ] || { echo "must run as root" >&2; exit 1; }

install -d -m 0755 "$QUADLET_DST"
install -m 0644 "$REPO_DIR"/quadlets/*.container "$QUADLET_DST"/

# Data dir for CRDB. Deployments bind-mount durable storage here.
install -d -m 0700 /var/lib/cockroach
# mTLS certs mountpoint; populated per-deployment.
install -d -m 0750 /etc/cockroach/certs

if [ "$PULL" = "1" ]; then
  # Image tag is pinned in quadlets/cockroachdb.container; bumping it is
  # a deliberate edit to this repo.
  podman pull ghcr.io/v-sekai/cockroach:e7195c11905a24a30768c6a9cab39eb571a30d25
fi

systemctl daemon-reload
echo "Installed. Start with: systemctl start cockroachdb.service"
