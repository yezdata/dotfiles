#!/usr/bin/env bash
set -euo pipefail

FOLDERS=("vs" "work" "courses")
BASE_LOCAL="/Users/jezva"
REMOTE_NAME="gdrive"

STATE_DIR="/Users/jezva/.local/state/rclone-backup"
LAST_RUN_FILE="$STATE_DIR/last_successful_sync"
LOCK_DIR="/tmp/rclone-backup.lockdir"
LOG_FILE="/Users/jezva/Library/Logs/rclone-backup.log"
IGNORE_FILE="/Users/jezva/.rcloneignore"

mkdir -p "$STATE_DIR" "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# 1. Atomický zámek přes mkdir
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script already running or stale lock exists ($LOCK_DIR)." >> "$LOG_FILE"
    exit 0
fi
# Trap automaticky uklidí lockdir při jakémkoliv exit kódu
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM

# 2. Kontrola napájení
ON_BATTERY=false
if pmset -g batt | grep -q "Battery Power"; then
    ON_BATTERY=true
fi

NOW=$(date +%s)
LAST_RUN=0
if [[ -f "$LAST_RUN_FILE" ]]; then
    LAST_RUN=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)
fi
ELAPSED=$(( NOW - LAST_RUN ))

# 3. Řízení intervalů (6 hodin = 21600 s na baterii)
if [ "$ON_BATTERY" = true ]; then
    if (( ELAPSED < 21600 )); then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] On battery: only ${ELAPSED}s elapsed since last sync (required 21600s). Skipping." >> "$LOG_FILE"
        exit 0
    fi
    CHECKERS=2
    TRANSFERS=2
else
    CHECKERS=4
    TRANSFERS=4
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting gdrive sync (Battery: $ON_BATTERY)..." >> "$LOG_FILE"

ALL_SUCCESS=true

# Sestavení volitelných argumentů pro exclude
EXCLUDE_ARGS=()
if [ -f "$IGNORE_FILE" ]; then
    EXCLUDE_ARGS+=("--exclude-from" "$IGNORE_FILE")
fi

for folder in "${FOLDERS[@]}"; do
    SRC="$BASE_LOCAL/$folder"
    DEST="$REMOTE_NAME:$folder"

    if [ ! -d "$SRC" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Warning: Local directory $SRC doesn't exist, skipping." >> "$LOG_FILE"
        continue
    fi

    if ! /opt/homebrew/bin/rclone sync "$SRC" "$DEST" \
        --fast-list \
        --checkers "$CHECKERS" \
        --transfers "$TRANSFERS" \
        "${EXCLUDE_ARGS[@]}" \
        --log-level NOTICE \
        --log-file "$LOG_FILE"; then
        
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error while synchronizing $SRC -> $DEST" >> "$LOG_FILE"
        ALL_SUCCESS=false
    fi
done

if [ "$ALL_SUCCESS" = true ]; then
    echo "$NOW" > "$LAST_RUN_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Synced successfully all directories." >> "$LOG_FILE"
fi
