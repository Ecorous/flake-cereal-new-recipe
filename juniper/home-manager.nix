{
  imports = [ ../common/home-manager.nix ];
  
  home-manager.users.ecorous = import ./ecorous.nix;
  home-manager.users.watch = import ./watch.nix;
}
