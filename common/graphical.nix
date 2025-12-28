{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
    _1password-gui.polkitPolicyOwners = [ "ecorous" ];
  };

  environment.systemPackages = with pkgs; [
    temurin-bin
    temurin-jre-bin-8
    temurin-jre-bin-17
    ghostty
    firefox
    vesktop
    element-desktop
    # beeper
    signal-desktop
    kdePackages.dolphin
    vscode-fhs
    mpv
    jellyfin-mpv-shim
    finamp
    (flameshot.override { enableWlrSupport = true; })
    localsend
    moonlight-qt
    pwvucontrol
    openrgb
    onlyoffice-desktopeditors
    twinkle
    jami
    steam-run
    protontricks
    protonup-ng
    protonup-qt
    jellyfin-media-player
    thunderbird
    tor-browser
    qbittorrent
    wtype
    via
    pulseaudio
    megasync
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
    "jitsi-meet-1.0.8792"
  ];

  services.xserver.xkb.layout = "gb";

  fonts.packages = with pkgs; [ 
    nerd-fonts.jetbrains-mono
    twitter-color-emoji
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetbrainsMono Nerd Font Mono" ];
      emoji = [ "Twitter Color Emoji" ];
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.libGL ];
  };

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  services.pipewire = import ./pipewire.nix;
}
