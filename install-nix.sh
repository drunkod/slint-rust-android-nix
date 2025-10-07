#!/bin/bash
set -e

echo "Installing Nix..."

sudo rm -rf /nix /tmp/nix
rm -rf ~/.nix-* ~/.config/nix ~/.local/state/nix

mkdir -p ~/.config/nix
echo "sandbox = false" > ~/.config/nix/nix.conf
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

sudo mkdir -p /nix
sudo chown $USER:$USER /nix

curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

echo "Moving to /tmp..."
sudo mv /nix /tmp/nix
sudo ln -sf /tmp/nix /nix
sudo chown -R $USER:$USER /tmp/nix

[ -e ~/.nix-profile/etc/profile.d/nix.sh ] && source ~/.nix-profile/etc/profile.d/nix.sh
[ -e ~/.local/state/nix/profiles/profile/etc/profile.d/nix.sh ] && source ~/.local/state/nix/profiles/profile/etc/profile.d/nix.sh

grep -q "nix-profile" ~/.bashrc || echo 'source ~/.nix-profile/etc/profile.d/nix.sh 2>/dev/null || source ~/.local/state/nix/profiles/profile/etc/profile.d/nix.sh' >> ~/.bashrc

nix --version
echo "✅ Done!"
