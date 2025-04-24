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

# Get last command display and put in a variable for further processing
$env.config = ($env.config | upsert hooks {
    display_output: {
        tee {table | print} | $env.last = $in
        # $env.last = $in
        # $env.last | table
    }
})

# retrieve last command output
def last [] {
  $env.last
}

let os_name = (sys host | get name | str downcase)
let os_long_version = (sys host | get long_os_version | str downcase)
let os_kernel = (sys host | get kernel_version | str downcase)

let windows = $os_name | str contains "windows"
let linux = ($os_long_version | str contains "linux") or ($os_name | str contains "linux")
let wsl = ($os_kernel | str contains "microsoft") and $linux

let proj = "flake-cereal-new-recipe"

if ($windows) {
    $env.ENIX_FLAKE_PATH = $"C:/Users/(whoami)/Projects/($proj)"
} else if ($wsl) {
    $env.ENIX_FLAKE_PATH = $"/mnt/c/Users/(whoami)/Projects/($proj)"
} else if ($linux) {
    $env.ENIX_FLAKE_PATH = $"/($proj)"
} else {
    panic "???"
}

let flake_path = $env.ENIX_FLAKE_PATH
# let nrb_path = $"path:($flake_path)#($host)"

def nrb_path [ host2="" ] {
    if ($host2 == "") {
        return $"path:($flake_path)#($host)"
    } else {
        return $"path:($flake_path)#($host2)"
    }
} 


alias wg = winget.exe
alias wgi = winget.exe install
alias wgs = winget.exe search

# alias nixos = sudo nixos-rebuild switch --flake path:($env.ENIX_FLAKE_PATH)#($host)
alias snrb = sudo nixos-rebuild
alias nrb = nixos-rebuild
alias nrbf = nrb switch --flake 
alias snrbf = snrb switch --flake

def nrbs-remote [target --ssh-host="placeholder" (-r) --sudo=true (-s)] {
    if ($ssh_host == "placeholder") {
        if ($sudo) {
            nrbf (nrb_path $target) --target-host ($target) --use-remote-sudo
        } else {
            nrbf (nrb_path $target) --target-host ($target)
        }
    } else {
        # nixos-rebuild switch --flake path:($env.ENIX_FLAKE_PATH)#($flake_name) --target-host ($ssh_host) --use-remote-sudo
        if ($sudo) {
            nrbf (nrb_path $target) --target-host ($ssh_host) --use-remote-sudo
        } else {
            nrbf (nrb_path $target) --target-host ($ssh_host)
        }
    }
}

def hn [name] {
    $host | str contains $name
}

def "nixos juniper" [] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    if (hn "juniper") { 
        nixos localhost
    } else {
        nrbs-remote juniper
    }
}
def "nixos elder" [] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    if (hn "elder") {
        nixos localhost
    } else {
        nrbs-remote elder -r root@elder -s false
    }
}
def "nixos wsl" [] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    if (hn "wsl") {
        nixos localhost
    } else {
        panic "We can't do WSL remotely."
    }
}
def "nixos wsl-nixos" [] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    nixos wsl
}
def "nixos yggdrasil" [] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    if (hn "yggdrasil") {
        nrbs
    } else {
        panic "just don't. please."
    }
}
def "nixos localhost" [--host=""] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    snrbf (nrb_path)
}

def "nixos all" [] {
    if ($windows) {
        print "warning: cannot build nixos on windows"
        return
    }
    if (hn "wsl") {
        print "warning: yggdrasil won't be rebuilt - won't be done remotely"
        do -i {
            nixos localhost
            nixos elder
            nixos juniper
        }
    } else if (hn "yggdrasil") {
        print "warning: wsl won't be rebuilt - cannot be done remotely"
        do -i {
            nixos localhost
            nixos elder
            nixos juniper
        }
    } else {
        print "warning: wsl won't be rebuilt - cannot be done remotely"
        print "warning: yggdrasil won't be rebuilt - not doing remotely"
        do -i {
            nixos elder
            nixos juniper
        }
    }
}

def nixos [] { 
    print "You must use one of the following subcommands. Using this command as-is will only produce this help message.\n"
    help nixos
}

def upload [file: string, --to:string --path:string = "/smb/shared" ] {
    mut realhost = $to;
    if ($realhost == "elder") {
        $realhost = "root@elder"
    } else {
        print $file $to $path
    }
    scp $file $"($realhost):($path)"
}

alias brctl = brightnessctl

def brctl_percentage [] {
    (brctl g | into int) / (brctl m | into int) * 100 | math round
}

if ($host == "elder") {
    print h
    alias update-www = cp -r /flake-cereal-new-recipe/files/www /srv/
}