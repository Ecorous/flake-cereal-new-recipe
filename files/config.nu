# Global configuration for Nushell

let host = (sys host | get hostname | str downcase)

# -----------------------------------------------------------
#  Prompt configuration
# -----------------------------------------------------------

$env.PROMPT_COMMAND = {||
    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let user = (whoami | str downcase)
    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let ssh = if "SSH_CONNECTION" in $env { "(ssh) " } else "" 
    let path_segment = $"($path_color)($ssh)($user)@($host) ($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}


# -----------------------------------------------------------
#  `last` command
#  Allows you to retrieve the output of the last command run
#  without running it again.
# -----------------------------------------------------------


# Get last command display and put in a variable for further processing
$env.config = ($env.config | upsert hooks {
    display_output: {
        tee {table | print} | $env.last = $in
    }
})

# retrieve last command output
def last [] {
  $env.last
}

# -----------------------------------------------------------
#  Utilities
# -----------------------------------------------------------

def hn [name] {
    $host | str contains $name
}


def brctl_percentage [] {
    (brctl g | into int) / (brctl m | into int) * 100 | math round
}

def "remove_old_kernels" [--duration: duration = 8wk] {
   ls /boot/kernels | where modified <= (date now) - $duration | each { rm -f $in.name } 
}


def exists [command: string] {
    if ($command == "") {
        error make {msg: "command cannot be empty"}
    }
    if ($command | str contains " ") {
        error make {msg: "command cannot contain spaces"}
    }
    if ($command | str contains "/") {
        error make {msg: "command cannot contain slashes"}
    }
    if ($command | str contains "\\") {
        error make {msg: "command cannot contain backslashes"}
    }
    not (which $command | is-empty) 
}

def "update-www" [] {
    do { cd /flake-cereal-new-recipe; git pull /flake-cereal-new-recipe }
    cp -r /flake-cereal-new-recipe/files/www /srv/www
}
if ($host != "elder") { hide update-www }


def forward [ --local-port(-l): int --remote-address(-r): string --expose(-e)=true --host(-h)="localhost" ] {
    let nu_cmd = "nu -c \"print \"listening.. press ctrl+c to exit\"; sleep (999wk * 100)\""
    if ($local_port == null) {
        error make {msg: "flag --local-port (-l) is required"}
    }
    if ($remote_address == null) {
        error make {msg: "flag --remote-address (-r) is required"}
    }
    if ($expose) {
        print "notice: exposing this port on all interfaces (this is perfectly normal)"
        ssh -o GatewayPorts=yes -v -L $"0.0.0.0:($local_port):($remote_address)" $host $nu_cmd
    } else {
        ssh -v -L $"127.0.0.1:($local_port):($remote_address)" $host $nu_cmd
    }
}


# -----------------------------------------------------------
#  WSL commands
# ------------------------------------------------------------


def "wsl list" [] {
    wsl.exe -l -v
    | into binary
    | decode utf-16
    | str downcase
    | detect columns --guess
    | reject version
    | upsert default { |r| $r.name | str contains "* " }
    | update name { str replace "* " "" }
    | upsert state { |r| $r.state == "running"}
    | rename -c {state: running}    
}

def "wsl default" [] {
    wsl list
    | where default == true
    | get name
    | first
}

def "wsl set-default" [name: string] {
    if ($name == "") {
        error make {msg: "name cannot be empty"}
    }
    if (not (wsl exists $name)) {
        error make {msg: "distro '$name' does not exist"}
    }
    wsl.exe --set-default $name
}

def "wsl exists" [name: string = ""] {
    if ($name == "") {
        return (not (wsl list | is-empty))
    }
    
    ($name | str downcase) in (wsl list | get name)
}

def "wsl run" [--distro(-d): string = "DEFAULT" command: closure] {
    view source $command | wsl.exe -d  (if (($distro | str downcase) == "default") { wsl default } else { $distro }) -- nu -l -c $"do ($in)"
}


# -----------------------------------------------------------
#  Variable setup
# -----------------------------------------------------------

let os_name = (sys host | get name | str downcase)
let os_long_version = (sys host | get long_os_version | str downcase)
let os_kernel = (sys host | get kernel_version | str downcase)

let windows = $os_name | str contains "windows"
let linux = ($os_long_version | str contains "linux") or ($os_name | str contains "linux")
let wsl = ($os_kernel | str contains "microsoft") and $linux

let proj = "flake-cereal-new-recipe"

mut wsl_for_nixos = false
if (exists wsl) {
    $wsl_for_nixos = ($windows and (wsl exists "nixos"))
} 
let wsl_for_nixos = $wsl_for_nixos


if ($windows) {
    $env.ENIX_FLAKE_PATH = $"C:/Users/(whoami)/Projects/($proj)"
} else if ($wsl) {
    $env.ENIX_FLAKE_PATH = $"/mnt/c/Users/(whoami)/Projects/($proj)"
} else if ($linux) {
    $env.ENIX_FLAKE_PATH = $"/($proj)"
} else {
    panic "??? maybe macos?"
}


let flake_path = $env.ENIX_FLAKE_PATH
# let nrb_path = $"path:($flake_path)#($host)"

# -----------------------------------------------------------
# Path setup
# -----------------------------------------------------------

use std "path add"
path add ~/.deno/bin

# -----------------------------------------------------------
#  Aliases
# -----------------------------------------------------------

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
alias brctl = brightnessctl






# -----------------------------------------------------------
#  NixOS-related commands.
#  Mainly used for remote builds.
# -----------------------------------------------------------

def nrb_path [ host2="" ] {
    if ($host2 == "") {
        return $"path:($flake_path)#($host)"
    } else {
        return $"path:($flake_path)#($host2)"
    }
} 

def nrbs-remote [target --ssh-host(-r)="placeholder" --sudo(-s)=true] {
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

def "nixos juniper" [] {
    if ($windows) {
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos juniper}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
    }
    if (hn "juniper") { 
        nixos localhost
    } else {
        nrbs-remote juniper
    }
}
def "nixos elder" [] {
    if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos elder}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
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
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos juniper}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
    }
    if (hn "wsl") {
        nixos localhost
    } else {
        panic "We can't do WSL remotely."
    }
}
def "nixos wsl-nixos" [] {
    if ($windows) {
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos wsl-nixos}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
    }
    nixos wsl
}
def "nixos yggdrasil" [] {
    if ($windows) {
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos yggdrasil}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
    }
    if (hn "yggdrasil") and not $wsl {
        snrbf (nrb_path)
    } else {
        panic "just don't. please."
    }
}
def "nixos localhost" [--host=""] {
    if ($windows) {
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos localhost}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
    }
    snrbf (nrb_path)
}

def "nixos all" [] {
    if ($windows) {
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos all}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
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
    scp $file $"($to | str replace 'elder' 'root@elder'):($path)"
}

# -----------------------------------------------------------
#  Completions
# ------------------------------------------------------------
    
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

# -----------------------------------------------------------
#  Fnm setup
# ------------------------------------------------------------

module fnm {
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

        fnm-env | load-env

        if ("__fnm_hooked" in $env) {
            if ($env.__fnm_hooked | describe ) == "string" {
                if ($env.__fnm_hooked | str contains "true") {
                    $env.__fnm_hooked = true
                } else {
                    $env.__fnm_hooked = false
                }
            }
        }

        if (not ($env | default false __fnm_hooked | get __fnm_hooked)) {
         $env.__fnm_hooked = true
        }
    }
}

if (exists fnm) {
    use fnm
}

