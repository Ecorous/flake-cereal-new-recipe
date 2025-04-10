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
    beeper
    signal-desktop
    kdePackages.dolphin
    vscode-fhs
    mpv
    jellyfin-mpv-shim
    finamp
    flameshot
    localsend
    thunderbird-latest-unwrapped
    moonlight-qt
    pwvucontrol
  ];

  services.xserver.xkb.layout = "gb";

  # FIXME do nixalien shit whatever im lazy https://github.com/thiagokokada/nix-alien?tab=readme-ov-file#nixos-installation-with-flakes

  fonts.fontconfig.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  hardware.graphics = { # TODO: do proper individual graphics for each system. nixos wiki on video acceleration
    enable = true;
    extraPackages = [ pkgs.libGL ];
  };

  services.pipewire = import ./pipewire.nix;
}