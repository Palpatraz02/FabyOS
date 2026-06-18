#!/bin/bash
# Stop execution if any command fails
set -e

# --- CONFIGURATION ---
REPO_URL="https://github.com/Palpatraz02/dotfiles.git"
# ---------------------

echo "🚀 Starting Chezmoi secure bootstrap..."

# 1. Detect package manager and install dependencies
if ! command -v chezmoi &> /dev/null || ! command -v age &> /dev/null || ! command -v bw &> /dev/null; then
    echo "📦 Dependencies missing. You must install chezmoi, age, and bitwarden-cli..."
    exit 1
fi

# 2. Recreate secure key layout
echo "📂 Setting up secure configuration paths..."
mkdir -p "$HOME/.config/chezmoi"

# 3. Authenticate and extract the decryption identity
echo "🌐 Configuring Bitwarden for the EU instance..."
bw config server https://vault.bitwarden.eu

echo "🔐 Authenticating with Bitwarden..."
# Try to login first (for fresh machines). If already logged in, fallback to unlock.
export BW_SESSION=$(bw login --raw 2>/dev/null || bw unlock --raw)

if [ -z "$BW_SESSION" ]; then
    echo "❌ Error: Failed to unlock Bitwarden vault. Aborting bootstrap process."
    exit 1
fi

echo "📥 Fetching Age Master Key from vault..."
# Grabs the exact text from your secure note
AGE_KEY=$(bw get notes "Chezmoi Age Master Key")

if [ -z "$AGE_KEY" ]; then
    echo "❌ Error: Could not find 'Chezmoi Age Master Key' in Bitwarden. Aborting."
    exit 1
fi

# Write key securely to disk with locked-down file permissions
echo "$AGE_KEY" > "$HOME/.config/chezmoi/key.txt"
chmod 600 "$HOME/.config/chezmoi/key.txt"
echo "🔒 Age decryption identity stored safely at ~/.config/chezmoi/key.txt"

# 4. Initialize and apply Chezmoi configuration state over HTTPS
echo "📥 Initializing and deploying configuration state from $REPO_URL..."
chezmoi init --apply "$REPO_URL"

echo "✅ Success! All dotfiles, application layouts, and secrets restored successfully."

# 5. Script Self-Destruction
echo "💥 Cleaning up setup artifacts. Self-destructing script..."
rm -- "$0"
