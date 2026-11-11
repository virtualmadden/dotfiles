{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home = {
    username = user;
    homeDirectory = "/Users/${user}";
    stateVersion = "24.11";
    packages = with pkgs; [
      # cli i use constantly
      ripgrep   # fast search
      fd        # fast find
      fzf       # fuzzy finder
      jq        # json on the command line
      gitleaks  # secret scanning in the dotfiles pre-commit hook
      lazygit
      podman-compose
      # the font everything renders in
      nerd-fonts.hack
    ];

    # rustup is keg-only in brew, so its cargo/rustc proxies need to be on PATH
    sessionPath = [
      "/opt/homebrew/opt/rustup/bin"
      "$HOME/.cargo/bin"
      # tfswitch links the selected terraform here
      "$HOME/bin"
    ];
    # rustup ships no toolchain; install stable plus what rust-analyzer needs (no-op once present)
    activation.rustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /opt/homebrew/opt/rustup/bin/rustup default stable
      run /opt/homebrew/opt/rustup/bin/rustup component add rust-analyzer rust-src
    '';

    # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
    file = {
      # brew's nvm keeps nvm.sh outside NVM_DIR; the oh-my-zsh nvm plugin loads it from ~/.nvm
      ".nvm/nvm.sh".source =
        config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/opt/nvm/libexec/nvm.sh";

      ".config/herdr".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
      ".claude/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

      ".claude/CLAUDE.md".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
      ".codex/AGENTS.md".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
      ".config/opencode/AGENTS.md".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
    };
  };
  fonts.fontconfig.enable = true;

  programs = {
    # also installs git and git-lfs, replacing apple's /usr/bin/git
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user.name = "Jonathan Madden";
        user.email = "virtualmadden@users.noreply.github.com";
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;      # ghost text from history
      syntaxHighlighting.enable = true;  # commands turn green when valid
      initContent = ''
        bindkey '^f' autosuggest-accept

        # nested login shells re-run brew shellenv, which pushes /opt/homebrew/bin
        # (and brew's node) ahead of nvm; move nvm's node back to the front
        [[ -n $NVM_BIN ]] && path=($NVM_BIN $path)
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "dotenv"
          "brew"
          "podman"
          "nvm"
          "gh"
          "git"
        ];
        theme = "";
      };
      shellAliases = {
        ".." = "cd ..";
        add = "git add .";
        push = "git push";
        pull = "git pull";
        m = "git switch main";
        cc = "claude --dangerously-skip-permissions";
        co = "codex --full-auto";
        docker = "podman";
      };
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;
        format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
        };
        cmd_duration.format = "[$duration]($style) ";
      };
    };
  };
}
