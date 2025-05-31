source ~/Projects/flake-cereal-new-recipe/files/nu/mommy.nu
source ~/Projects/flake-cereal-new-recipe/files/nu/zerotier.nu

# hide "nixos juniper"
# hide "nixos elder"
# hide "nixos localhost"
# hide "nixos yggdrasil"
# hide "nixos all"

# alias nixos_run = wsl -d nixos nu --config "~/.config/nushell/config.nu" -c 

# def "nixos juniper" [] {
#     nixos_run "nixos juniper"
# }

# def "nixos elder" [] {
#     nixos_run "nixos elder"
# }

# def "nixos wsl" [] {
#     nixos_run "nixos wsl"
# }

# def "nixos wsl-nixos" [] {
#     nixos_run "nixos wsl-nixos"
# }

# def "nixos yggdrasil" [] {
#     nixos_run "nixos yggdrasil"
# }   

# def "nixos localhost" [--host=""] {
#     nixos_run $"nixos localhost --host=($host)"
# }

# def "nixos all" [] {
#     nixos_run "nixos all"
# }