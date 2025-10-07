#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📦 Nix Installation for Codespaces                   ║${NC}"
echo -e "${BLUE}║     Optimized for Android Development                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# --- Detect User ---
CURRENT_USER=${SUDO_USER:-$(whoami)}
USER_HOME=$(eval echo "~$CURRENT_USER")

echo -e "${GREEN}👤 User:${NC} $CURRENT_USER"
echo -e "${GREEN}🏠 Home:${NC} $USER_HOME"
echo ""

# --- Check Disk Space ---
echo -e "${YELLOW}💾 Checking disk space...${NC}"
df -h | grep -E "(Filesystem|/tmp|overlay)"
echo ""

# --- Pre-installation Cleanup ---
if [ -d "/nix" ]; then
    echo -e "${YELLOW}⚠️  Existing /nix directory found!${NC}"
    read -p "Remove existing installation? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}🗑️  Removing old installation...${NC}"
        sudo rm -rf /nix
        rm -rf "$USER_HOME/.nix-profile" "$USER_HOME/.nix-defexpr" "$USER_HOME/.nix-channels"
    else
        echo -e "${RED}❌ Aborted.${NC}"
        exit 1
    fi
fi

# --- Create Nix Config Directory ---
echo -e "${BLUE}📝 Creating Nix configuration...${NC}"
mkdir -p "$USER_HOME/.config/nix"

# --- Create nix.conf ---
cat > "$USER_HOME/.config/nix/nix.conf" <<'EOF'
# Core Settings
sandbox = false
experimental-features = nix-command flakes
filter-syscalls = false

# Build Settings
build-dir = /tmp/nix-builds
max-jobs = auto
cores = 0

# Space Management
auto-optimise-store = true
min-free = 2147483648
max-free = 5368709120

# Keep Builds Clean
keep-build-log = false
keep-derivations = false
keep-outputs = false

# Download Optimization
download-buffer-size = 268435456
connect-timeout = 5

# Unfree Packages (Android SDK)
allow-unfree = true
EOF

echo -e "${GREEN}✓ nix.conf created${NC}"

# --- Create Temporary Build Directories ---
echo -e "${BLUE}📁 Creating build directories...${NC}"
mkdir -p /tmp/nix-builds /tmp/nix-tmp
echo -e "${GREEN}✓ Build directories created${NC}"

# --- Install Nix ---
echo -e "${BLUE}📦 Installing Nix...${NC}"
sh <(curl --proto '=https' --tlsv1.2 -sSf -L https://nixos.org/nix/install) \
    --no-daemon \
    --yes

echo -e "${GREEN}✓ Nix installed${NC}"

# --- Move /nix to /tmp for More Space ---
echo -e "${BLUE}🔄 Moving Nix store to /tmp partition...${NC}"
if [ -d "/nix" ] && [ ! -L "/nix" ]; then
    sudo mv /nix /tmp/nix
    sudo ln -s /tmp/nix /nix
    echo -e "${GREEN}✓ Nix store moved to /tmp${NC}"
fi

# --- Set Ownership ---
echo -e "${BLUE}🔐 Setting permissions...${NC}"
sudo chown -R "$CURRENT_USER:$CURRENT_USER" /tmp/nix
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.config/nix"
echo -e "${GREEN}✓ Permissions set${NC}"

# --- Add Environment Variables to Shell ---
echo -e "${BLUE}🔧 Configuring shell environment...${NC}"

# Backup existing bashrc
cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.backup.$(date +%s)"

# Add Nix configuration to .bashrc
cat >> "$USER_HOME/.bashrc" <<'EOF'

# ═══════════════════════════════════════════════════════
# Nix Configuration
# ═══════════════════════════════════════════════════════

# Load Nix profile
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

# Build directories
export TMPDIR=/tmp/nix-tmp
export NIX_BUILD_TOP=/tmp/nix-builds
export NIXPKGS_ALLOW_UNFREE=1

# Android Development
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Cargo optimization (if using Rust)
export CARGO_HOME="${CARGO_HOME:-/tmp/cargo-home}"
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-/tmp/cargo-target}"

# Path additions
export PATH="$HOME/.nix-profile/bin:$PATH"

EOF

echo -e "${GREEN}✓ Shell configuration updated${NC}"

# --- Source the Profile ---
echo -e "${BLUE}🔄 Loading Nix environment...${NC}"
source "$USER_HOME/.nix-profile/etc/profile.d/nix.sh"

# --- Verify Installation ---
echo ""
echo -e "${BLUE}✅ Verifying installation...${NC}"
nix --version
echo ""

# --- Show Configuration ---
echo -e "${YELLOW}📋 Current Configuration:${NC}"
nix show-config | grep -E "(sandbox|build-dir|store-dir|experimental)" || true
echo ""

# --- Disk Space Summary ---
echo -e "${YELLOW}💾 Disk Space After Installation:${NC}"
df -h | grep -E "(Filesystem|/tmp|overlay)"
echo ""
if [ -d "/nix/store" ] || [ -d "/tmp/nix/store" ]; then
    echo -e "${YELLOW}📦 Nix Store Size:${NC}"
    du -sh /nix/store 2>/dev/null || du -sh /tmp/nix/store 2>/dev/null || echo "N/A"
fi
echo ""

# --- Create Utility Scripts ---
echo -e "${BLUE}🛠️  Creating utility scripts...${NC}"

# Cleanup script
cat > "$USER_HOME/nix-cleanup.sh" <<'EOF'
#!/bin/bash
echo "🧹 Cleaning Nix store..."
echo ""

# Show before
echo "Before cleanup:"
df -h | grep -E "(Filesystem|/tmp|overlay)"
du -sh /nix/store 2>/dev/null || du -sh /tmp/nix/store 2>/dev/null
echo ""

# Clean
nix-collect-garbage -d
nix-store --optimise

# Clean temp
rm -rf /tmp/nix-builds/* /tmp/nix-tmp/* 2>/dev/null

# Show after
echo ""
echo "After cleanup:"
df -h | grep -E "(Filesystem|/tmp|overlay)"
du -sh /nix/store 2>/dev/null || du -sh /tmp/nix/store 2>/dev/null
echo ""
echo "✅ Cleanup complete!"
EOF

chmod +x "$USER_HOME/nix-cleanup.sh"

# Info script
cat > "$USER_HOME/nix-info.sh" <<'EOF'
#!/bin/bash
echo "╔════════════════════════════════════════════════════════╗"
echo "║  📦 Nix Environment Information                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🔧 Nix Version:"
nix --version
echo ""
echo "📁 Store Location:"
ls -la / | grep nix
echo ""
echo "💾 Disk Usage:"
df -h | grep -E "(Filesystem|/tmp|overlay)"
echo ""
echo "📦 Store Size:"
du -sh /nix/store 2>/dev/null || du -sh /tmp/nix/store 2>/dev/null
echo ""
echo "⚙️  Configuration:"
nix show-config | grep -E "(sandbox|build-dir|store-dir|experimental-features)"
echo ""
echo "🌍 Environment Variables:"
env | grep -E "(NIX|TMPDIR|ANDROID|CARGO)" | sort
echo ""
EOF

chmod +x "$USER_HOME/nix-info.sh"

echo -e "${GREEN}✓ Utility scripts created:${NC}"
echo -e "  • ${YELLOW}~/nix-cleanup.sh${NC} - Clean up Nix store"
echo -e "  • ${YELLOW}~/nix-info.sh${NC}    - Show Nix environment info"
echo ""

# --- Final Instructions ---
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Installation Complete!                             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo ""
echo -e "1️⃣  Reload your shell:"
echo -e "    ${BLUE}source ~/.bashrc${NC}"
echo ""
echo -e "2️⃣  Verify installation:"
echo -e "    ${BLUE}nix --version${NC}"
echo -e "    ${BLUE}~/nix-info.sh${NC}"
echo ""
echo -e "3️⃣  Enter your development environment:"
echo -e "    ${BLUE}nix develop${NC}"
echo ""
echo -e "4️⃣  Run cleanup when needed:"
echo -e "    ${BLUE}~/nix-cleanup.sh${NC}"
echo ""
echo -e "${GREEN}🎉 Happy hacking!${NC}"
echo ""