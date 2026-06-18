#!/bin/bash
# Stop execution if any command fails
set -e

# --- CONFIGURATION ---
REPO_URL="https://github.com/Palpatraz02/dotfiles.git"
# ---------------------

echo "🚀 Starting Chezmoi secure bootstrap..."

# 1. Detect package manager and install dependencies
if ! command -v chezmoi &> /dev/null || ! command -v age &> /dev/null; then
    echo "📦 Dependencies missing. Yu must install chezmoi and age..."
    exit 1
fi

# 2. Recreate secure key layout
echo "📂 Setting up secure configuration paths..."
mkdir -p "$HOME/.config/chezmoi"

# 3. Interactively capture the decryption identity
echo "🔑 Please paste your Age private key (starts with 'AGE-SECRET-KEY-1...'):"
# Read input silently so the secret key doesn't leak onto the monitor screen
read -rs AGE_KEY

if [ -z "$AGE_KEY" ]; then
    echo "❌ Error: No Age key provided. Aborting bootstrap process."
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
