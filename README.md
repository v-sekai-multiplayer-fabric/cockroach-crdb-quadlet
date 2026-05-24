# cockroach-crdb-image

V-Sekai CRDB VM image: single-node CockroachDB with mTLS, run as a
podman quadlet on top of `linux-base-image`. Built once per release via
packer; consumed by the `infra` repo as the qcow2 for
`harvester_virtualmachine.crdb`.

## What's in the image

Inherits everything from `linux-base-image` (AlmaLinux 9 + podman +
chrony + qemu-guest-agent), and adds:

- `/etc/containers/systemd/cockroachdb.container` — podman quadlet
  running `ghcr.io/v-sekai/cockroach` in `start-single-node` mode
- `/var/lib/cockroach` — data dir (`harvester_volume` bind-mounted
  here by infra-side cloud-init)
- `/etc/cockroach/certs` — mountpoint for the mTLS PKI; certs come
  via a per-VM Kubernetes Secret + KubeVirt cloud-init data source

The cockroach binary is NOT installed natively. The CRDB image
(`ghcr.io/v-sekai/cockroach:<sha>`) is pre-pulled into podman's local
store so first boot is fast. Image tag is pinned in
`configs/quadlets/cockroachdb.container` and bumped by editing this
repo + re-baking.

## Build

CI on push to main + weekly schedule. Local:

```sh
cd packer
bash scripts/prepare-cidata.sh
packer init build.pkr.hcl
packer build build.pkr.hcl
ls ../output/
```

## Inheritance

Pin the parent version explicitly in `build.pkr.hcl`:

```hcl
variable "source_image_url" {
  default = "https://github.com/v-sekai-multiplayer-fabric/linux-base-image/releases/download/v0.1.0/linux-base-image.qcow2"
}
```
