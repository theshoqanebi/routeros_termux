#!/data/data/com.termux/files/usr/bin/bash
#
# RouterOS CHR launcher for Termux
#
# Resource values are read from a config file if one exists. Only the keys
# present in the config override the defaults below; any key that is missing
# keeps its default value.

# ---------------- Defaults ----------------
RAM=1024          # guest memory in MB
CPU_CORES=2       # number of vCPUs
CPU_MODEL=max     # qemu -cpu model
ACCEL=tcg         # qemu accelerator

# ---------------- Load overrides ----------------
# File format is KEY=VALUE (no spaces around =).
CFG="$PREFIX/etc/mikrotik/resource.cfg"
if [ -f "$CFG" ]; then
    # shellcheck disable=SC1090
    . "$CFG"
    echo "Loaded resource config: $CFG"
fi

IMG="${PREFIX:-/data/data/com.termux/files/usr}/share/mikrotik/chr-7.23.1.img"

echo "RAM: ${RAM} MB | cores: ${CPU_CORES} | cpu: ${CPU_MODEL} | accel: ${ACCEL}"

exec qemu-system-x86_64 \
  -machine accel="${ACCEL}" \
  -cpu "${CPU_MODEL}" \
  -m "${RAM}" \
  -smp "${CPU_CORES}" \
  -drive file="${IMG}",format=raw,if=virtio \
  -netdev user,id=wan,hostfwd=tcp::2222-:22,hostfwd=tcp::8291-:8291,hostfwd=tcp::8080-:80,hostfwd=tcp::8728-:8728,hostfwd=tcp::8729-:8729 \
  -device virtio-net-pci,netdev=wan \
  -netdev socket,id=lan1,listen=:10001 \
  -device virtio-net-pci,netdev=lan1 \
  -netdev socket,id=lan2,listen=:10002 \
  -device virtio-net-pci,netdev=lan2 \
  -netdev socket,id=lan3,listen=:10003 \
  -device virtio-net-pci,netdev=lan3 \
  -nographic