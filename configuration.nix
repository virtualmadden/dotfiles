{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  home-manager.backupFileExtension = "backup";
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    autoMigrate = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "kunchenguid/tap"
    ];
    brews = [
      "awscli"
      "gh"
      "go"
      "herdr"
      "neovim"
      "nvm"
      "pi-coding-agent"
      "python@3.15"
      "rustup"
      "tfswitch"
    ];
    casks = [
      "1password"
      "bruno"
      "chatgpt"
      "claude"
      "claude-code"
      "cursor"
      "discord"
      "github"
      "gitkraken"
      "iterm2"
      "kunchenguid/tap/baby-menu"
      "notion"
      "podman-desktop"
      "visual-studio-code"
      "wezterm"
    ];
  };
}