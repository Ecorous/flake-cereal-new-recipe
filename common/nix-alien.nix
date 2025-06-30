{ self, inputs, ... }:
{
  environment.systemPackages = with inputs.nix-alien.packages.x86_64-linux; [
    nix-alien
  ];
<<<<<<< HEAD
}
=======
}
>>>>>>> 0938a866a31de7f98db4a8b129b2e76057fae2a2
