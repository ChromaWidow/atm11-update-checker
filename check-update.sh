#!/bin/bash
set -euo pipefail

URL="https://www.curseforge.com/minecraft/modpacks/all-the-mods-11/files/all?page=1&pageSize=20"
STATE_FILE="/opt/minecraft-updater/state.txt"
LOG="/opt/minecraft-updater/update.log"

log() { echo "[$(date '+%F %T')] $1" >> "$LOG"; }

PAGE=$(curl -s -A "Mozilla/5.0" "$URL")

# Extrait le premier lien de fichier (le plus récent) depuis la page de listing
LATEST_PATH=$(echo "$PAGE" | grep -oP '/minecraft/modpacks/all-the-mods-11/files/\d+' | head -1 || true)

if [ -z "$LATEST_PATH" ]; then
  log "ERREUR: impossible de parser la page CurseForge"
  exit 1
fi

LAST_SEEN=$(cat "$STATE_FILE" 2>/dev/null || echo "")

if [ "$LATEST_PATH" != "$LAST_SEEN" ]; then
  log "Nouvelle version détectée: https://www.curseforge.com$LATEST_PATH"
  echo "$LATEST_PATH" > "$STATE_FILE"
  echo "NOUVELLE VERSION: https://www.curseforge.com$LATEST_PATH" > /opt/minecraft-updater/UPDATE_AVAILABLE
else
  log "Aucune nouvelle version (actuel: $LAST_SEEN)"
fi
