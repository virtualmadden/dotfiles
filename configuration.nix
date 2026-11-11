{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  users.users.${user} = {
    home = "/Users/${user}";
  };
  # touch id for sudo; reattach makes it work inside herdr/tmux sessions too
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
  home-manager.backupFileExtension = "backup";
  system = {
    primaryUser = user;
    stateVersion = 6;
    defaults = {
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
  };
  nix-homebrew = {
    enable = true;
    autoMigrate = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";  # remove anything not listed here
      autoUpdate = true;
      extraFlags = [ "--force" ];
    };
    taps = [
      "virtualmadden/tap"
    ];
    brews = [
      "awscli"
      "biome"
      "gh"
      "go"
      "herdr"
      "neovim"
      "nvm"
      "pi-coding-agent"
      "podman"  # brew's build ships krunkit for the libkrun machine; nixpkgs' does not
      "python@3.15"
      "rustup"
      "tfswitch"
      "treehouse"
      "wimlib"
      "virtualmadden/tap/gac-redux"
    ];
    casks = [
      "1password"
      "bruno"
      "chatgpt"
      "claude"
      "claude-code"
      "cursor"
      "discord"
      "elgato-stream-deck"
      "github"
      "handy"
      "insta360-link-controller"
      "logi-options+"
      "logitune"
      "notion"
      "podman-desktop"
      "visual-studio-code"
    ];
  };
}
