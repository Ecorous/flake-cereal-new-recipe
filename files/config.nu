# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

let host = (sys host | get hostname | str downcase)

$env.PROMPT_COMMAND = {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let user = (whoami | str downcase)
    

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($user)@($host) ($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

let os_name = (sys host | get name | str downcase)
let os_long_version = (sys host | get long_os_version | str downcase)
let os_kernel = (sys host | get kernel_version | str downcase)


if ($os_name | str contains "Windows") {
    $env.ENIX_FLAKE_PATH = $"C:/Users/(whoami)/Projects/flake-cereal-new-recipe"
} else if (($os_kernel | str contains "microsoft") and ($os_long_version | str contains "linux")) { # wsl2
    $env.ENIX_FLAKE_PATH = $"/mnt/c/Users/(whoami)/Projects/flake-cereal-new-recipe"
} else if ($os_name | str contains "Linux") {
    $env.ENIX_FLAKE_PATH = "/flake-cereal-new-recipe"
}

alias wg = winget.exe
alias wgi = winget.exe install
alias wgs = winget.exe search

alias nrbsh = sudo nixos-rebuild switch --flake path:($env.ENIX_FLAKE_PATH)#($host)
alias nrbs = sudo nixos-rebuild switch --flake path:($env.ENIX_FLAKE_PATH)
alias nrb = sudo nixos-rebuild switch

def nrbs-remote [ssh_host target_host --use-remote-sudo=true] {
    nixos-rebuild switch --flake path:($env.ENIX_FLAKE_PATH)#($target_host) --target-host ($ssh_host) --use-remote-sudo
}

alias brctl = brightnessctl

def brctl_percentage [] {
    (brctl g | into int) / (brctl m | into int) * 100 | math round
}