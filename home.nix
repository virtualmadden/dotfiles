{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    podman
    podman-compose
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;

  # rustup is keg-only in brew, so its cargo/rustc proxies need to be on PATH
  home.sessionPath = [
    "/opt/homebrew/opt/rustup/bin"
    "$HOME/.cargo/bin"
    # tfswitch links the selected terraform here
    "$HOME/bin"
  ];
  # rustup ships no toolchain; install stable plus what rust-analyzer needs (no-op once present)
  home.activation.rustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /opt/homebrew/opt/rustup/bin/rustup default stable
    run /opt/homebrew/opt/rustup/bin/rustup component add rust-analyzer rust-src
  '';

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
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

  programs.starship = {
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

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  # brew's nvm keeps nvm.sh outside NVM_DIR; the oh-my-zsh nvm plugin loads it from ~/.nvm
  home.file.".nvm/nvm.sh".source =
    config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/opt/nvm/libexec/nvm.sh";

  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

}