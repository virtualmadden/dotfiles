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
    brews = [
      "autoconf"
      "aws-c-auth"
      "aws-c-cal"
      "aws-c-common"
      "aws-c-compression"
      "aws-c-event-stream"
      "aws-c-http"
      "aws-c-io"
      "aws-c-mqtt"
      "aws-c-s3"
      "aws-c-sdkutils"
      "aws-checksums"
      "awscli"
      "ca-certificates"
      "gh"
      "go"
      "herdr"
      "libgit2"
      "libssh2"
      "llhttp"
      "llvm"
      "lz4"
      "m4"
      "mpdecimal"
      "neovim"
      "nvm"
      "openssl@4"
      "pkgconf"
      "pi-coding-agent"
      "pyenv"
      "python@3.15"
      "readline"
      "rust"
      "rustup"
      "s2n"
      "sqlite"
      "tfswitch"
      "xz"
      "z3"
      "zstd"
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
      "notion"
      "podman-desktop"
      "visual-studio-code"
      "wezterm"
    ];
  };
}