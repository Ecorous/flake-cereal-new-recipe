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

use std "path add"

if ($windows) {
    $env.ENIX_FLAKE_PATH = $"C:/Users/(whoami)/Projects/($proj)"
} else if ($wsl) {
    $env.ENIX_FLAKE_PATH = $"/mnt/c/Users/(whoami)/Projects/($proj)"
} else if ($linux) {
    $env.ENIX_FLAKE_PATH = $"/($proj)"
} else {
    panic "???"
}

path add ~/.deno/bin

let flake_path = $env.ENIX_FLAKE_PATH
# let nrb_path = $"path:($flake_path)#($host)"

def nrb_path [ host2="" ] {
    if ($host2 == "") {
        return $"path:($flake_path)#($host)"
    } else {
        return $"path:($flake_path)#($host2)"
    }
} 

alias gc = git commit -S -a -m
alias g = git

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

# print $host == elder
# print $host == "elder"
if ($host == "elder") {
    # print h

    "alias update-www = cp -r /flake-cereal-new-recipe/files/www /srv/" | save -f /tmp/update-www.nu
    # source /tmp/update-www.nu
}


def "update-www" [] {
    do { cd /flake-cereal-new-recipe; git pull /flake-cereal-new-recipe }
    cp -r /flake-cereal-new-recipe/files/www /srv/www
}
if ($host != "elder") { hide update-www }


def portforward [ --local-port(-l): int --remote-address(-r): string --expose(-e)=true --host(-h)="localhost" ] {

    let nu_cmd = "nu -c \"print \"listening.. press ctrl+c to exit\"; sleep (999wk * 100)\""
    if ($local_port == null) {
        error make {msg: "flag --local-port (-l) is required"}
    }
    if ($remote_address == null) {
        error make {msg: "flag --remote-address (-r) is required"}
    }
    if ($expose) {
        print "notice: exposing this port on all interfaces (this is perfectly normal)"
    } else {
        ssh -v -L $"127.0.0.1:($local_port):($remote_address)" $host $nu_cmd
    }
}



    
let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        # carapace completions are incorrect for nu
        # nu => $fish_completer
        # fish completes commits and branch names in a nicer way
        # git => $fish_completer
        # carapace doesn't have completions for asdf
        # asdf => $fish_completer
        # use zoxide completions for zoxide commands
        # __zoxide_z | __zoxide_zi => $zoxide_completer
        _ => $carapace_completer
    } | do $in $spans
}
$env.config.completions.external = {
    enable: true,
    completer: $external_completer,
};

export-env {
    def fnm-env [] {
        let vars = (
            fnm env --shell bash
            | str replace -a 'export ' ''
            | str replace -a '"' ''
            | lines
            | split column '='
            | rename name value
            | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value }
        )

        let fnm_path = ($vars.PATH | str replace ":$PATH" "")
        $vars | upsert PATH ($env.PATH | prepend $fnm_path)
    }

    if not (which fnm | is-empty) {
        fnm-env | load-env

        if (not ($env | default false __fnm_hooked | get __fnm_hooked)) {
            $env.__fnm_hooked = true

            # $env.config = (
                # $env.config | default {} | upsert hooks (
                    # $env.config.hooks | default {} | upsert env_change (
                        # $env.config.hooks.env_change | default {} | upsert PWD (
                            # ($env.config.hooks.env_change.PWD | default []) ++ [{
                            #     |before, after|
                            #     if ([.nvmrc .node-version] | path exists | any { |it| $it }) {
                            #         fnm use
                            #     }
                            # }]
                        # )
                    # )
                # )
            # )
        }
    }
}