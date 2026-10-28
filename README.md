# dotfiles

My macOS setup, managed declaratively with [nix-darwin](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew). One command rebuilds the whole machine: system defaults, Homebrew packages and apps, shell, and app configs.

## What's in here

| Path | Purpose |
| --- | --- |
| `flake.nix` | Flake entry point. Defines the `mac` darwin configuration and the `user` it applies to. |
| `configuration.nix` | System level: macOS defaults, Homebrew brews and casks. |
| `home.nix` | User level (Home Manager): CLI packages, zsh, starship prompt, and symlinks for app configs. |
| `home/` | Raw config files that get symlinked into `~`. |
| `rebuild.sh` | Links this repo to `~/.dotfiles` and runs `darwin-rebuild switch`. |

### System (`configuration.nix`)

- macOS defaults: dark mode, fast key repeat, show all file extensions, autohiding Dock, Finder list view, no desktop icons, tap to click.
- `brews` lists only the tools used directly; Homebrew manages their dependencies. Rust comes from `rustup` (not the `rust` formula).
- Homebrew is managed by nix-homebrew. `onActivation.cleanup = "zap"` means **anything not listed in `taps`, `brews`, or `casks` gets uninstalled** on rebuild.
- Targets Apple Silicon (`aarch64-darwin`). Change `nixpkgs.hostPlatform` to `x86_64-darwin` for Intel.

### User (`home.nix`)

- CLI tools from nixpkgs: `ripgrep`, `fd`, `fzf`, `jq`, `lazygit`, `podman`, `podman-compose`, plus the Hack Nerd Font.
- nvm from Homebrew, loaded by the oh-my-zsh `nvm` plugin through a `~/.nvm/nvm.sh` link to brew's script; Node versions live in `~/.nvm`.
- rustup's `cargo`/`rustc` proxies (`/opt/homebrew/opt/rustup/bin`) and `~/.cargo/bin` on `PATH`, since brew's `rustup` is keg-only. Rebuild installs the `stable` toolchain with `rust-analyzer` and `rust-src`.
- zsh with autosuggestions (accept with `Ctrl+F`) and syntax highlighting.
- oh-my-zsh with the `dotenv`, `brew`, `podman`, `nvm`, `gh`, and `git` plugins; no theme, since Starship owns the prompt.
- Starship prompt.
- Shell aliases:

  | Alias | Command |
  | --- | --- |
  | `..` | `cd ..` |
  | `add` | `git add .` |
  | `push` | `git push` |
  | `pull` | `git pull` |
  | `m` | `git switch main` |
  | `cc` | `claude --dangerously-skip-permissions` |
  | `co` | `codex --full-auto` |
  | `docker` | `podman` |

### App configs (`home/`)

These are linked with `mkOutOfStoreSymlink`, so the files in `~` point straight at this repo. Edits take effect immediately without a rebuild, and changes show up in `git status`.

| Repo file | Linked to |
| --- | --- |
| `home/.config/wezterm/` | `~/.config/wezterm` - WezTerm (rose-pine-moon, translucent, dims unfocused windows) |
| `home/.config/herdr/` | `~/.config/herdr` - herdr with tmux-style `Ctrl+B` keybindings |
| `home/.claude/settings.json` | `~/.claude/settings.json` - Claude Code theme and status line |
| `home/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md` - shared global instructions for coding agents |

`home/CLAUDE.md` is not linked anywhere; it only points Claude Code at `home/AGENTS.md` when working inside `home/`.

## Setup

1. Install Nix with the [Determinate Nix installer](https://determinate.systems/nix-installer/). This config sets `nix.enable = false` because Determinate manages the Nix daemon.
2. Clone this repo anywhere:

   ```sh
   git clone <this-repo> ~/Documents/github/dotfiles
   cd ~/Documents/github/dotfiles
   ```

3. If your macOS username isn't `virtualmadden`, change the `user` line in `flake.nix`.
4. Build and switch. On the very first run `darwin-rebuild` isn't installed yet, so bootstrap it through Nix:

   ```sh
   ln -sfn "$PWD" ~/.dotfiles
   sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/.dotfiles#mac
   ```

Podman runs in its own VM on macOS. After the first rebuild, create and start it:

```sh
podman machine init
podman machine start
```

## Day to day

After changing any `.nix` file, rebuild:

```sh
./rebuild.sh
```

This re-points `~/.dotfiles` at the repo and runs `sudo darwin-rebuild switch --flake ~/.dotfiles#mac`. Files that Home Manager would overwrite are moved aside with a `.backup` extension.

To add a Homebrew package or app, add it to `brews` or `casks` in `configuration.nix` and rebuild. To remove one, delete it from the list; the `zap` cleanup uninstalls it.

To update pinned inputs (nixpkgs, nix-darwin, Home Manager, nix-homebrew):

```sh
nix flake update
./rebuild.sh
```
