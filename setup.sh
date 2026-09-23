#!/bin/sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_CONFIG_DIR="$HOME/.config"
TARGET_BIN_DIR="$HOME/bin"

mkdir -p "$TARGET_CONFIG_DIR" "$TARGET_BIN_DIR"


# 1: File link
for app in aerospace fish ghostty git tmux zed; do
    if [ "$app" = "aerospace" ] && [ "$(uname -s)" != "Darwin" ]; then
        continue
    fi

    if [ -d "$DOTFILES_DIR/$app" ]; then
        echo "Synchronizing $app"
        
        find "$DOTFILES_DIR/$app" -type f | while read -r src_file; do
            
            rel_path="${src_file#$DOTFILES_DIR/}"
            dst_file="$TARGET_CONFIG_DIR/$rel_path"

            mkdir -p "$(dirname "$dst_file")"

            if [ -e "$dst_file" ] || [ -L "$dst_file" ]; then
                rm -f "$dst_file"
            fi

            ln -s "$src_file" "$dst_file"
            echo "  [OK] $rel_path"
        done
    fi
done


# 2: Dir link
if [ -d "$DOTFILES_DIR/nvim" ]; then
    echo "Synchronizing nvim/"
    dst_nvim="$TARGET_CONFIG_DIR/nvim"

    if [ -e "$dst_nvim" ] || [ -L "$dst_nvim" ]; then
        rm -rf "$dst_nvim"
    fi

    ln -s "$DOTFILES_DIR/nvim" "$dst_nvim"
    echo "  [OK] nvim/"
fi



# 3: Rclone & Backup Scripts
RCLONE_DIR="$DOTFILES_DIR/rclone_sync"

if [ -d "$RCLONE_DIR" ]; then
    echo "Synchronizing rclone_sync/"

    # .rcloneignore -> ~/.rcloneignore
    src_ignore="$RCLONE_DIR/.rcloneignore"
    dst_ignore="$HOME/.rcloneignore"

    if [ -f "$src_ignore" ]; then
        if [ -e "$dst_ignore" ] || [ -L "$dst_ignore" ]; then
            rm -f "$dst_ignore"
        fi

        ln -s "$src_ignore" "$dst_ignore"
        echo "  [OK] .rcloneignore"
    fi

    # gdrive-backup.sh -> ~/bin/gdrive-backup.sh
    src_backup="$RCLONE_DIR/gdrive-backup.sh"
    dst_backup="$TARGET_BIN_DIR/gdrive-backup.sh"

    if [ -f "$src_backup" ]; then
        chmod +x "$src_backup"

        if [ -e "$dst_backup" ] || [ -L "$dst_backup" ]; then
            rm -f "$dst_backup"
        fi

        ln -s "$src_backup" "$dst_backup"
        echo "  [OK] bin/gdrive-backup.sh"
    fi

    src_plist="$RCLONE_DIR/com.jezva.gdrivebackup.plist"
    dst_plist_dir="$HOME/Library/LaunchAgents"
    dst_plist="$dst_plist_dir/com.jezva.gdrivebackup.plist"

    if [ -f "$src_plist" ] && [ "$(uname -s)" = "Darwin" ]; then
        mkdir -p "$dst_plist_dir"

        if [ -e "$dst_plist" ] || [ -L "$dst_plist" ]; then
            rm -f "$dst_plist"
        fi

        ln -s "$src_plist" "$dst_plist"
        echo "  [OK] Library/LaunchAgents/com.jezva.gdrivebackup.plist"

        if ! launchctl print "gui/$(id -u)/com.jezva.gdrivebackup" >/dev/null 2>&1; then
            echo "  [INFO] LaunchAgent is not loaded. Load manually: launchctl bootstrap gui/$(id -u) $dst_plist"
        fi
    fi

fi
