{
  imports = [
    ../common/ecorous.nix
    ../common/virtualisation-hm.nix
  ];

  home.file.".config/nushell/autoload/yggdrasil.nu".source = ../files/nu/yggdrasil.nu;
  home.file.".config/nushell/mommy.nu".source = ../files/nu/mommy.nu;
}
