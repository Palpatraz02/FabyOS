#!/bin/bash
# Stop execution if any command fails
set -e

PROTON_PASS_BRAVE_SYNC_REF="${PROTON_PASS_BRAVE_SYNC_REF:-pass://${PROTON_PASS_VAULT:-Personal}/${PROTON_PASS_BRAVE_SYNC_ITEM:-Brave Sync Code}/${PROTON_PASS_BRAVE_SYNC_FIELD:-note}}"
BRAVE_SYNC_SETUP_URL="brave://settings/braveSync/setup"

echo "🦁 Configuring Brave..."

if ! command -v brave-browser &> /dev/null; then
    echo "❌ Error: Brave is not installed. Aborting."
    exit 1
fi

if ! command -v pass-cli &> /dev/null; then
    echo "❌ Error: Proton Pass CLI is not installed. Aborting."
    exit 1
fi

echo "🌐 Setting Brave as the default browser..."
if command -v xdg-settings &> /dev/null; then
    xdg-settings set default-web-browser brave-browser.desktop
fi

if command -v xdg-mime &> /dev/null; then
    xdg-mime default brave-browser.desktop text/html
    xdg-mime default brave-browser.desktop x-scheme-handler/http
    xdg-mime default brave-browser.desktop x-scheme-handler/https
fi

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
    echo "❌ Error: Failed to authenticate with Proton Pass. Aborting."
    exit 1
fi

echo "📥 Fetching Brave Sync Code from Proton Pass..."
BRAVE_SYNC_CODE=$(pass-cli item view "$PROTON_PASS_BRAVE_SYNC_REF")

if [ -z "$BRAVE_SYNC_CODE" ]; then
    echo "❌ Error: Could not find the Brave Sync Code at '$PROTON_PASS_BRAVE_SYNC_REF'. Aborting."
    exit 1
fi

echo "📋 Copying Brave Sync Code to clipboard..."
if command -v wl-copy &> /dev/null; then
    printf "%s" "$BRAVE_SYNC_CODE" | wl-copy
elif command -v xclip &> /dev/null; then
    printf "%s" "$BRAVE_SYNC_CODE" | xclip -selection clipboard
elif command -v xsel &> /dev/null; then
    printf "%s" "$BRAVE_SYNC_CODE" | xsel --clipboard --input
else
    echo "⚠️ Warning: No supported clipboard tool found. The sync code could not be copied automatically."
fi

echo "🚀 Opening Brave Sync setup..."
brave-browser "$BRAVE_SYNC_SETUP_URL" &> /dev/null &

echo "✅ Brave is now the default browser. Paste the copied sync code into the Brave Sync setup page."
