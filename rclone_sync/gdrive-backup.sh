#!/usr/bin/env bash
set -euo pipefail

FOLDERS=("vs" "work" "courses")
BASE_LOCAL="/Users/jezva"
REMOTE_NAME="gdrive"

STATE_DIR="/Users/jezva/.local/state/rclone-backup"
LAST_RUN_FILE="$STATE_DIR/last_successful_sync"
LOCK_DIR="/tmp/rclone-backup.lockdir"
PID_FILE="$LOCK_DIR/pid"
LOG_FILE="/Users/jezva/Library/Logs/rclone-backup.log"
IGNORE_FILE="/Users/jezva/.rcloneignore"
MAX_LOG_BYTES=5242880

mkdir -p "$STATE_DIR" "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

rotate_log() {
    local size
    size=$(stat -f%z "$LOG_FILE" 2>/dev/null || echo 0)
    if (( size > MAX_LOG_BYTES )); then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
    fi
}

acquire_lock() {
    if mkdir "$LOCK_DIR" 2>/dev/null; then
        echo $$ > "$PID_FILE"
        return 0
    fi

    local existing_pid
    existing_pid=$(cat "$PID_FILE" 2>/dev/null || true)

    if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
        log "Backup already running (PID: $existing_pid). Skipping."
        return 1
    fi

    # Reclaim stale lock left after a hard crash or SIGKILL
    rm -rf "$LOCK_DIR"
    mkdir "$LOCK_DIR"
    echo $$ > "$PID_FILE"
    log "Removed stale lock (PID: ${existing_pid:-unknown})."
    return 0
}

rotate_log

if ! acquire_lock; then
    exit 0
fi
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# Avoid piping pmset into grep -q under pipefail, which can trigger SIGPIPE
BATT_STATUS=$(pmset -g batt)
ON_BATTERY=false
if [[ "$BATT_STATUS" == *"Battery Power"* ]]; then
    ON_BATTERY=true
fi

NOW=$(date +%s)
LAST_RUN=0
if [[ -f "$LAST_RUN_FILE" ]]; then
    LAST_RUN=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)
fi
ELAPSED=$(( NOW - LAST_RUN ))

if [[ "$ON_BATTERY" == true && "$FORCE" == false ]]; then
    if (( ELAPSED < 21600 )); then
        log "On battery: ${ELAPSED}s elapsed (required 21600s). Skipping."
        exit 0
    fi
    CHECKERS=2
    TRANSFERS=2
else
    CHECKERS=4
    TRANSFERS=4
fi

EXCLUDE_ARGS=()
if [[ -f "$IGNORE_FILE" ]]; then
    EXCLUDE_ARGS+=("--exclude-from" "$IGNORE_FILE")
fi

ARCHIVE_DATE=$(date '+%Y-%m-%d')
ALL_SUCCESS=true

for folder in "${FOLDERS[@]}"; do
    SRC="$BASE_LOCAL/$folder"
    DEST="$REMOTE_NAME:$folder"
    BACKUP_DIR="$REMOTE_NAME:_archive/$ARCHIVE_DATE/$folder"

    if [[ ! -d "$SRC" ]]; then
        log "Warning: $SRC does not exist, skipping."
        continue
    fi

    if ! /opt/homebrew/bin/rclone sync "$SRC" "$DEST" \
        --fast-list \
        --checkers "$CHECKERS" \
        --transfers "$TRANSFERS" \
        --tpslimit 5 \
        --tpslimit-burst 5 \
        --backup-dir "$BACKUP_DIR" \
        "${EXCLUDE_ARGS[@]}" \
        --log-level NOTICE \
        --log-file "$LOG_FILE"; then
        log "Error synchronizing $SRC -> $DEST"
        ALL_SUCCESS=false
    fi
done

if [[ "$ALL_SUCCESS" == true ]]; then
    echo "$NOW" > "$LAST_RUN_FILE"
    log "Sync completed successfully (Battery: $ON_BATTERY)."
else
    osascript -e 'display notification "Check ~/Library/Logs/rclone-backup.log" with title "Google Drive Backup Failed"'
fi
