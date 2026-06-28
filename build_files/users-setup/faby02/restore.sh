#!/bin/bash
# Stop execution if any command fails
set -e

# --- CONFIGURATION ---
REPO_URL="https://github.com/Palpatraz02/dotfiles.git"
PROTON_PASS_AGE_KEY_REF="${PROTON_PASS_AGE_KEY_REF:-pass://${PROTON_PASS_VAULT:-Personal}/${PROTON_PASS_AGE_KEY_ITEM:-Chezmoi Age Master Key}/${PROTON_PASS_AGE_KEY_FIELD:-note}}"
# ---------------------

echo "🚀 Starting Chezmoi secure bootstrap..."

# 1. Detect package manager and install dependencies
if ! command -v chezmoi &> /dev/null || ! command -v age &> /dev/null || ! command -v pass-cli &> /dev/null; then
    echo "📦 Dependencies missing. You must install chezmoi, age, and proton-pass-cli..."
    exit 1
fi

# 2. Recreate secure key layout
echo "📂 Setting up secure configuration paths..."
mkdir -p "$HOME/.config/chezmoi"


echo "🔐 Authenticating with Proton Pass..."

if ! pass-cli test &> /dev/null; then
    echo "👤 Please log in to your Proton Pass account:"
    if [ -n "${PROTON_PASS_EMAIL:-}" ]; then
        pass-cli login --interactive "$PROTON_PASS_EMAIL"
    else
        pass-cli login
    fi
fi

if ! pass-cli test &> /dev/null; then
    echo "❌ Error: Failed to authenticate with Proton Pass. Aborting bootstrap process."
    exit 1
fi

echo "📥 Fetching Age Master Key from vault..."
AGE_KEY=$(pass-cli item view "$PROTON_PASS_AGE_KEY_REF")

if [ -z "$AGE_KEY" ]; then
    echo "❌ Error: Could not find the Age key at '$PROTON_PASS_AGE_KEY_REF' in Proton Pass. Aborting."
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
