{
  imports = [ ../common/home-manager.nix ];
  
  home-manager.users.ecorous = import ../juniper/ecorous.nix;
}
