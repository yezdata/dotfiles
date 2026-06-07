#!/bin/sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_CONFIG_DIR="$HOME/.config"

mkdir -p "$TARGET_CONFIG_DIR"


# 1: File link
for app in fish ghostty git tmux; do
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
