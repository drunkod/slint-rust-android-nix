#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.
CALLING_USER=${SUDO_USER:-$(whoami)}

# Get the home directory for that specific user.
# Using 'eval' is a robust way to expand the tilde (~) for any user.
USER_HOME=$(eval echo "~$CALLING_USER")

echo "---"
echo "Running script for user: $CALLING_USER"
echo "Using home directory:    $USER_HOME"
echo "---"

echo "📦 Setting up Cargo to use /tmp..."
echo ""

# Set up directories
export CARGO_HOME=/tmp/cargo-home
export CARGO_TARGET_DIR=/tmp/cargo-target

mkdir -p "$CARGO_HOME"
mkdir -p "$CARGO_TARGET_DIR"

# Create config file
cat > "$CARGO_HOME/config.toml" <<'EOF'
[build]
target-dir = "/tmp/cargo-target"
incremental = true

[net]
git-fetch-with-cli = true
offline = false

[profile.release]
opt-level = "z"     # Optimize for size
lto = true          # Link-time optimization
codegen-units = 1   # Single codegen unit for better optimization
strip = true        # Strip symbols
EOF

echo "✅ Cargo configured to use /tmp"
echo ""
echo "Environment variables to add to your shell:"
echo "  export CARGO_HOME=/tmp/cargo-home"
echo "  export CARGO_TARGET_DIR=/tmp/cargo-target"
echo ""
echo "Configuration saved to: $CARGO_HOME/config.toml"
