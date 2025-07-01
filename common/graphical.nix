{ config, lib, pkgs, ... }:

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
    thunderbird-latest-unwrapped
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
  ];

  services.xserver.xkb.layout = "gb";

  fonts.fontconfig.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

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
