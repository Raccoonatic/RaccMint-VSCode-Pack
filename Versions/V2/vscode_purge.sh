#!/bin/bash

echo "=== WARNING: Wiping all traces of VS Code from the system ==="

# 1. Purge the package and clean up orphaned dependencies
sudo apt purge -y code
sudo apt autoremove -y

# 2. Remove user configurations and settings
echo "Removing user settings..."
rm -rf "$HOME/.config/Code"

# 3. Remove all extensions
echo "Removing extensions..."
rm -rf "$HOME/.vscode"

# 4. Remove caches and local data directories
echo "Removing caches and local state..."
rm -rf "$HOME/.cache/Code"
rm -rf "$HOME/.local/share/code"

# 5. Remove the local desktop application launcher
echo "Removing local desktop entry..."
rm -f "$HOME/.local/share/applications/code.desktop"

# 6. Remove system-wide overrides made by your custom pack
echo "Cleaning up system-wide assets..."
sudo rm -f /usr/share/pixmaps/code.png

# 7. Reset core code directory ownership just in case
sudo rm -rf /usr/share/code

echo "=== VSCode purged successfully. ==="
