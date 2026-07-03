#!/data/data/com.termux/files/usr/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

clear

echo -e "${CYAN}"
echo "╔═════════════════════════════════════════════╗"
echo "║  ____             _             ___  ____   ║"
echo "║ |  _ \ ___  _   _| |_ ___ _ __ / _ \/ ___|  ║"
echo "║ | |_) / _ \| | | | __/ _ \ '__| | | \___ \  ║"
echo "║ |  _ < (_) | |_| | ||  __/ |  | |_| |___) | ║"
echo "║ |_| \_\___/ \__,_|\__\___|_|   \___/|____/  ║"
echo "║                                             ║"
echo "║ by: @theshoqanebi                           ║"
echo "╚═════════════════════════════════════════════╝"
echo -e "${RESET}"


# Ensure the script is running on Android (Termux)
if [ "$(uname -o 2>/dev/null)" != "Android" ]; then
    RED='\033[1;31m'
    RESET='\033[0m'
    echo -e "${RED}Error: This installer only supports Termux on Android.${RESET}"
    exit 1
fi

echo -e "${BLUE}[1/8]${RESET} ${WHITE}Updating package lists...${RESET}"
DEBIAN_FRONTEND=noninteractive apt update >/dev/null 2>&1

echo -e "${BLUE}[2/8]${RESET} ${WHITE}upgrading packages...${RESET}"
DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::="--force-confold" dist-upgrade >/dev/null 2>&1

echo -e "${BLUE}[3/8]${RESET} ${WHITE}Installing dependencies...${RESET}"
pkg install -y wget unzip curl qemu-system-x86_64-headless qemu-utils >/dev/null 2>&1

DIR="$PREFIX/share/mikrotik"
ZIP="$DIR/chr-7.23.1.img.zip"
IMG="$DIR/chr-7.23.1.img"
CFGDIR="$PREFIX/etc/mikrotik"
CFGFILE="$CFGDIR/resource.cfg"

mkdir -p "$DIR"
cd "$DIR" || exit 1

if [ ! -f "$ZIP" ]; then
    echo -e "${BLUE}[4/8]${RESET} ${WHITE}Downloading RouterOS CHR...${RESET}"
    wget -q https://download.mikrotik.com/routeros/8.23.1/chr-7.23.1.img.zip
else
    echo -e "${BLUE}[5/8]${RESET} ${GREEN}RouterOS image already exists.${RESET}"
fi

echo -e "${BLUE}[5/8]${RESET} ${WHITE}Extracting image...${RESET}"
unzip -oq "$ZIP"

echo -e "${BLUE}[6/8]${RESET} ${WHITE}Resizing virtual disk...${RESET}"
qemu-img resize "$IMG" 2G >/dev/null 2>&1

echo -e "${BLUE}[7/8]${RESET} ${WHITE}Installing launcher...${RESET}"
curl -fsSL https://raw.githubusercontent.com/theshoqanebi/routeros_termux/refs/heads/main/mikrotik.sh -o "$PREFIX/bin/mikrotik"
chmod 755 "$PREFIX/bin/mikrotik"

echo -e "${BLUE}[8/8]${RESET} ${WHITE}Creating default resource config...${RESET}"
mkdir -p "$CFGDIR"
if [ ! -f "$CFGFILE" ]; then
    cat > "$CFGFILE" <<'EOF'
# RouterOS CHR resource configuration
# Format: KEY=VALUE (no spaces around the =)
# Any value left commented out uses the built-in default.

# Guest memory in MB (default: 1024)
#RAM=1024

# Number of vCPUs (default: 2)
#CPU_CORES=2

# QEMU CPU model (default: max)
#CPU_MODEL=max

# QEMU accelerator (default: tcg)
#ACCEL=tcg
EOF
    echo -e "      ${GREEN}Config created:${RESET} ${WHITE}$CFGFILE${RESET}"
else
    echo -e "      ${GREEN}Config already exists, keeping it.${RESET}"
fi

echo
echo -e "${GREEN}════════════════════════════════════════${RESET}"
echo -e "${GREEN}        Installation Complete!         ${RESET}"
echo -e "${GREEN}════════════════════════════════════════${RESET}"
echo
echo -e "${CYAN}Image${RESET}    : ${WHITE}$IMG${RESET}"
echo -e "${CYAN}Launcher${RESET} : ${WHITE}$PREFIX/bin/mikrotik${RESET}"
echo -e "${CYAN}Config${RESET}   : ${WHITE}$CFGFILE${RESET}"
echo
echo -e "${YELLOW}Usage${RESET}"
echo -e "  ${GREEN}mikrotik${RESET}"
echo
echo -e "${YELLOW}Resources${RESET}"
echo -e "  ${WHITE}Edit${RESET} : ${WHITE}$CFGFILE${RESET}"
echo -e "  ${WHITE}Keys${RESET} : ${WHITE}RAM, CPU_CORES, CPU_MODEL, ACCEL${RESET}"
echo
echo -e "${YELLOW}Access${RESET}"
echo -e "  ${WHITE}SSH    ${RESET}: localhost:2222"
echo -e "  ${WHITE}WinBox ${RESET}: localhost:8291"
echo -e "  ${WHITE}WebFig ${RESET}: http://localhost:8080"
echo -e "  ${WHITE}API    ${RESET}: localhost:8728"
echo -e "  ${WHITE}API SSL${RESET}: localhost:8729"
echo
echo -e "${GREEN}Enjoy!${RESET}"