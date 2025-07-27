{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./upgrade-diff.nix ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/London";

  networking.nameservers = lib.mkDefault [
    "192.168.69.1"
    "192.168.1.242"
    "1.1.1.1"
    "1.0.0.1"
  ];

  nix.settings.trusted-users = [
    "root"
    "ecorous"
  ];

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  environment.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";

  };

  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ../pkgs/nushell.nix { })
    helix
    btop
    python3
    hyfetch
    p7zip-rar
    wget
    fastfetch
    gay
    blahaj
    kitty.terminfo
    ghostty.terminfo
    nixfmt-rfc-style
    parted
    usbutils
    pciutils
    dig
    nss_latest
    nss_latest.tools
    wakeonlan
    libnotify
    psmisc
    feh
    carapace
    ripgrep
    ripgrep-all
  ];

  users.defaultUserShell = pkgs.nushell;
  users.users.root.shell = pkgs.nushell;
  users.users.root.initialPassword = "colonthree";
  users.users.ecorous = {
    description = "Dawn";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.nushell;
  };

  programs = {
    git = {
      enable = true;
      config = {
        init.defaultBranch = "mistress";
        gpg.format = "ssh";
        # user = {
        #   name = "Ecorous";
        #   email = "ecorous@outlook.com";
        #   signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIazU90lTF7rPY11hzMA2CdOXmdaOBTZWJ25PBDl1gzS";
        # };

        # "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        # commit.gpgSign = false;
      };
    };
  };

  #  _1password-gui.enable = true;
  # _1password-gui.polkitPolicyOwners = [ "ecorous" ];
  services = {
    tailscale.enable = true;
    openssh.enable = true;
    zerotierone.enable = true;
  };

  # security.sudo.wheelNeedsPassword = false;
  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = false;
  };

  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # no touchy. bad.
}
