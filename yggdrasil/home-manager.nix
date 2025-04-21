{
  imports = [ ../common/home-manager.nix ];

  home-manager.users.ecorous = import ./ecorous.nix;
}