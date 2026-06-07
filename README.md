# Dotfiles

My personal configurations for macOS and Linux. Managed via a custom, lightweight installation script that acts as a safe, granular replacement for GNU Stow.

## Architecture & How It Works

The `setup.sh` script utilizes a hybrid approach to creating symlinks:

1. **Granular Symlinking (`fish`, `ghostty`, `git`, `tmux`)**: The script iterates through the repository file by file. It creates symlinks *only* for the files that actually exist in this repository. Other local files (e.g., auto-generated fish completions, history, or local caches) inside system's `~/.config` remain completely untouched.
2. **Bulk Symlinking (`nvim`)**: The entire Neovim directory is symlinked as a single unit, making it easier to manage the complex, nested Lua structure.

## Usage
1. Clone the repository
```sh
   git clone https://github.com/yezdata/dotfiles.git ~/dotfiles
   cd ~/dotfiles
```

2. Grant execution permissions to the script
```sh
chmod +x setup.sh
```

3. Run the installation
```sh
./setup.sh
```
