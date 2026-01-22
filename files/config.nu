# Global configuration for Nushell



let host = (sys host | get hostname | str downcase)

# -----------------------------------------------------------
#  Prompt configuration
# -----------------------------------------------------------

$env.EDITOR = "hx";
$env.VISUAL = "hx";
$env.config.buffer_editor = "hx";

$env.PROMPT_COMMAND = {||
    let dir = match (do -i {
        if ('home-path' in $nu) {
            $env.PWD | path relative-to $nu.home-path
        } else { ($env.PWD | path relative-to $nu.home-dir)} }) {
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

$env.TRANSIENT_PROMPT_COMMAND_RIGHT = null;
$env.config.highlight_resolved_externals = true
$env.config.color_config.shape_external = "light_red"
$env.config.color_config.shape_external_resolved = "light_cyan_bold" 


# `nu-highlight` with default colors
#
# Custom themes can produce a lot more ansi color codes and make the output
# exceed discord's character limits
def nu-highlight-default [] {
    let IN = $in
    $env.config.color_config = {}
     $IN | nu-highlight
 }

 # Copy the current commandline, add syntax highlighting, wrap it in a
 # markdown code block, copy that to the system clipboard.
 #
 # Perfect for sharing code snippets on discord
 def "nu-keybind commandline-copy" []: nothing -> nothing {
     use std/clip
     commandline
     | nu-highlight-default
     | [
         '```ansi'
         $in
         '```'
     ]
     | str join (char nl)
     | clip copy -a
 }

 $env.config.keybindings ++= [
     {
         name: copy_color_commandline
         modifier: control_alt
         keycode: char_c
         mode: [emacs vi_insert vi_normal]
         event: {
             send: executehostcommand
             cmd: 'nu-keybind commandline-copy'
         }
     }
]


# -----------------------------------------------------------
#  `last` command
#  Allows you to retrieve the output of the last command run
#  without running it again.
# -----------------------------------------------------------


let mime_to_lang = {
    application/json: json,
    application/xml: xml,
    application/yaml: yaml,
    text/csv: csv,
    text/tab-separated-values: tsv,
    text/x-toml: toml,
    text/markdown: markdown,
}

$env.config.hooks.display_output = {
    metadata access {|meta| match $meta.content_type? {
        null => {}
        "application/x-nuscript" | "application/x-nuon" | "text/x-nushell" => { nu-highlight },
        $mimetype if $mimetype in $mime_to_lang => { ^bat -Ppf --language=($mime_to_lang | get $mimetype) },
        _ => {},
    }}
    | if (term size).columns >= 100 { table -e -o } else { table -o } | default "" 
}


# Get last command display and put in a variable for further processing
# $env.config = ($env.config | upsert hooks {
#     display_output: {
#         if (term size).columns >= 100 { table -e } else { table } | default ""
#     }
# })


# retrieve last command output
def last_c [] {
  $env.last
}


# -----------------------------------------------------------
#  Utilities
# -----------------------------------------------------------

def nudo [c: closure] {
    to nuon | sudo $nu.current-exe --stdin -c $"from nuon | do (view source $c) | to nuon" | from nuon
}

def --wrapped "nushell test" [--no-config-home, --no-backtrace ...rest] {
    if not $no_config_home {
        $env.XDG_CONFIG_HOME = "";
    }
    if not $no_backtrace {
        $env.RUST_BACKTRACE = 1;
    }
    cargo test --workspace ...$rest  -- --skip custom_arguments_and_subcommands --skip folder_with_directorycompletions --skip folder_with_directorycompletions_do_not_collapse_dots --skip folder_with_directorycompletions_with_three_trailing_dots
}

# Download file, using the filename provided by the url if necessary
def download [
    url: string,
    filename: string = "" # If filename is left empty, it will attempt to get the filename from the url
    --overwrite(-o) # Overwrite an existing file if it's present
] {
    let urldata = $url | path parse
    let actual_filename = if ($filename | is-empty) {
        $"($urldata.stem | url decode).($urldata.extension)"
    } else {
        $filename
    }

    let filename_span = if ($filename | is-empty) {
        metadata $url | get span | upsert start {|x| $x.start + ($urldata.parent | split chars | length) + 1} # | upsert end { |x| $x.end - 1 }
    } else {
        metadata $filename | get span
    }

    let decoded_msg = if ($filename | is-empty) { if $"($urldata.stem | url decode).$($urldata.extension)" != $"($urldata.stem).($urldata.extension)" {
        $" \(($urldata.stem).($urldata.extension) -> ($urldata.stem | url decode).($urldata.extension)\)"
    } else { "" } } else { "" }
    
    #  let span = $urlmeta.span | upsert start {|x| $x.start + ($urldata.parent | split chars | length) + 2} | upsert end { |x| $x.end - 1 }
    if not $overwrite and ($actual_filename | path exists) {
        error make {
            msg: "file already exists",
            label: {
                text: $"this file already exists($decoded_msg)",
                span: $filename_span
            },
            help: "try using the --overwrite(-o) flag"
        }
    }
    http get $url | save -f $actual_filename
}

# Create a symlink
def symlink [
        file: string
        link: string
] {
        # Remove any existing link - Just in case
        if ($link | path exists) { rm $link }

         # Create the link - OS specific
         if ($nu.os-info.family == 'windows') {
                 # Windows
                 # Path strings require additional sanitization for mklink
                 if not (is-admin) and (which sudo | is-not-empty) {
                   sudo cmd /c mklink /D $'"($link | path expand | str replace '/' '\' --all)"' $'"($file | path expand | str replace '/' '\' --all)"' #"
                 } else {
                     ^mklink /D $'"($link | path expand | str replace '/' '\' --all)"' $'"($file | path expand | str replace '/' '\' --all)"' #"
                  }
         } else {
                 # Linux/Mac/BSD
                 ^ln -s ($file | path expand) ($link | path expand)
         }
 }

def ghurl []: string -> string {
    $"git@github.com:($in)"
}

def gheurl []: string -> string {
    $"git@github.com:Ecorous/($in)"
}

def hn [name] {
    $host | str contains $name
}


def brctl_percentage [] {
    (brctl g | into int) / (brctl m | into int) * 100 | math round
}

def remove_old_kernels [--duration: duration = 8wk] {
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
    let nu_cmd = "nu -c \"print 'listening.. press ctrl+c to exit'; sleep (999wk * 100)\""
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

def --wrapped "git nix-commit-push" [...rest] {
    nixfmt **/*.nix; gc ...$rest; gpu
}

alias gncp = git nix-commit-push

# -----------------------------------------------------------
#  Zoxide setup
# -----------------------------------------------------------
const __zoxide_path = ($nu.default-config-dir | path join ".zoxide.nu")
if (exists zoxide) {
    zoxide init nushell | save -f $__zoxide_path
}

source (if ($__zoxide_path | path exists) { $__zoxide_path } else { null })

# -----------------------------------------------------------
#  Media Renamer
# -----------------------------------------------------------

def "mediafix tv" [--dry-run(-d)] {
    let x = (input "Are you sure you want to do this? [y/N] ")
    ls | get name
       | parse "{show}.S{season}E{episode}.{junk}.mkv"
       | each { |x|
            {
              old: $"($x.show).S($x.season)E($x.episode).($x.junk).mkv",
              new: $"($x.show | str replace '.' ' ') S($x.season)E($x.episode).mkv"
            }
        }
       | each { |y| if $dry_run { $y } else { mv $y.old $y.new; $y } }
}

# -----------------------------------------------------------
#  WinGet commands
# -----------------------------------------------------------


def flagcheck [var, name] {
    match ($var | describe) {
        "bool" => {
            if $var {
                return $"--($name) ($var) "
            }  else {
                return ""
            }
        },
        "string" | "float" | "int" | "number" => {
            if $var != "" {
                return $"--($name) ($var) "
            } else {
                return ""
            }
        },
    }
}

use nu/utils/i.nu inherit

def --wrapped  "winget search" [--id: string,                     # Filter results by id
                                --name: string,                   # Filter results by name
                                --moniker: string,                # Filter results by moniker
                                --tag: string,                    # Filter results by tag
                                --command: string,                # Filter results by command 
                                --source(-s): string,             # Find package using the specified source
                                --count(-n): int,                 # Show no more than specified number of results (between 1 and 1000)
                                --exact(-e),                      # Find package using exact match
                                --header: string,                 # Optional Windows-Package-Manager REST source HTTP header
                                --authentication-mode: string,    # Specify authentication window preference (silent, silentPreferred, or interactive)
                                --authentication-account: string, # Specify the account to be used for authentication
                                --accept-source-agreements,       # Accept all source agreements during source operations
                                --versions,                       # Show available versions of the package
                                --wait,                           # Prompts the user to press any key before exiting
                                --logs,                           # Open the default logs location 
                                --verbose,                        # Enables verbose logging for winget
                                --ignore-warnings,                # Suppresses warning outputs
                                --disable-interactivity,          # Disable interactive prompts
                                --proxy: string,                  # Set a proxy to use for this execution
                                --no-proxy,                       # Disable the use of proxy for this execution
                                ...rest] {
    # let flag_str = $'(if $id != "" {$"--id ($id) "} else {""})(if $name != "" {$"--name ($name)"} else {""})'
    let flag_table = inherit $id $name $moniker $tag $command $source $count $exact $header $authentication_mode $authentication_account $accept_source_agreements $versions $wait $logs $verbose $ignore_warnings $disable_interactivity $proxy $no_proxy
                          | transpose key value
                          | compact key
    let flag_str = $flag_table | each { flagcheck $in.value $in.key } | str join | split row " " | where { |x| $x != "" }
    ^winget search ...$flag_str ...$rest
    | lines
    | drop nth 1
    | each { str trim }
    | each { |x| if ($x == "<additional entries truncated due to result limit>") {print "warn: additional entries truncated due to result limit"} else {$x}}
    | upsert 0 {
        split row ""
        | skip until { |x| $x == "N" }
        | str join
    }
    | str join (char nl)
    | detect columns --guess
}

def --wrapped "winget show" [...rest] {
    ^winget show ...$rest
    | parse "{key}: {val}"
    | upsert key { str trim }
    | transpose -dir
}

def --wrapped "winget list" [...rest] {
    ^winget list ...$rest
    | lines
    | drop nth 1
    | each { str trim }
    | upsert 0 {
        split row ""
        | skip until { |x| $x == "N" }
        | str join
    }
    | str join (char nl)
    | detect columns --guess
}

# -----------------------------------------------------------
#  Zerotier commands
# -----------------------------------------------------------

def "zerotier networks" [] {
    sudo zerotier-cli listnetworks -j 
    | from json 
    | select id name assignedAddresses status type
    | rename id name addresses 
    | each { |it|
        $it
        | upsert addresses ($it.addresses | to text)
        | upsert status ($it.status | str downcase)
        | upsert type ($it.type | str downcase)
     }
}

def "zerotier join" [id: string] {
    sudo zerotier-cli join -j $id
    | from json
    | select id name assignedAddresses status type
    | rename id name addresses
    | upsert addresses ($in.addresses | {ipv6: $in.0, ipv4: $in.1})
    | upsert status ($in.status | str downcase)
    | upsert type ($in.type | str downcase)
}

# -----------------------------------------------------------
# Tailscale commands
# -----------------------------------------------------------

alias tss = tailscale status
def "tailscale status" [] {
    tss
    | str replace --all -r " {1,}" "  " 
    | lines 
    | parse "{ip}  {host}  {user}  {os}  {data}" 
    | upsert data {|r| $r.data | str replace --all -r " {1,}" " "}
}


# -----------------------------------------------------------
#  WSL commands
# -----------------------------------------------------------


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
    if ($name | is-empty) {
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

def "wsl ssh-agent" [
    --distro(-d): string = "DEFAULT"
    --foreground(-f)
] {
    let d =  if ($distro == "DEFAULT") {
        wsl default
    } else {
        if (not (wsl exists ($distro | str downcase) )) {
            error make {msg: "distro '$distro' does not exist, please use 'wsl list' to see available distros."}
        }
        $distro | str downcase
    }
    if ($d != "nixos") and ($d != "archlinux") {
        error make {msg: $"distro ($distro) is not supported for ssh-agent forwarding, only 'nixos' and 'archlinux' are supported."}
    }
    if $foreground {
        ssh $"($d).wsl" -A -T "$env.SSH_AUTH_SOCK | save -f /tmp/ssh-agent-sock.txt; bash"
    } else {
        print { id: (job spawn {
            ssh $"($d).wsl" -A -T "$env.SSH_AUTH_SOCK | save -f /tmp/ssh-agent-sock.txt; bash"
        })}

    }

}

def "wsl run" [
    --distro(-d): string = "DEFAULT"
    --forward-ssh-agent(-a)
    --run-shell(-s)
    command: closure
    ] {
    let distro_to_use = if ($distro == "DEFAULT") {
        wsl default
    } else {
        if (not (wsl exists ($distro | str downcase) )) {
            error make {msg: "distro '$distro' does not exist, please use 'wsl list' to see available distros."}
        }
        $distro | str downcase
    }
    mut job_id = -2048
    if $forward_ssh_agent and ($distro_to_use == "nixos") { # forwarding is only setup properly for nixos
        print "starting ssh agent forwarding for nixos distro"
        $job_id = job spawn { ssh nixos.wsl -A -T "$env.SSH_AUTH_SOCK | save -f /tmp/ssh-agent-sock.txt; print \"started ssh forwarding\"; bash" }
    }
    if $run_shell {
        wsl.exe -d $distro_to_use -- nu -l 
    } else {
        view source $command | wsl.exe -d  $distro_to_use -- nu -l -c $"do ($in)" 
    }
    
    if $forward_ssh_agent and ($distro_to_use == "nixos") {
        print "killing ssh agent forwarding job"
        if ($job_id != -2048) {
            if (job list | is-not-empty) {
                if (job list | where id == $job_id | is-empty) {
                    print "warning: job with id $job_id not found, maybe it finished already?"
                } else {
                    job list
                    job kill $job_id
                }
            }
        }
    }
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



let flake_path = $env.ENIX_FLAKE_PATH? | default (if ($windows) {
    $"C:/Users/(whoami)/Projects/($proj)"
} else if ($wsl) {
     $"/mnt/c/Users/(whoami)/Projects/($proj)"
} else if ($linux) {
    $"/($proj)"
} else {
    error make { msg: "maybe macos? failed setting flake path and $env.ENIX_FLAKE_PATH was not set"}
})

if ($windows) {
    $env.HOME = $env.USERPROFILE
}

source ./catppuccin_mocha.nu

# -----------------------------------------------------------
# Services command setup
# -----------------------------------------------------------
def "services list" [] {
    pwsh -c "Get-Service" 
    | collect 
    | lines 
    | where { |x| not ($x | str contains "Get-Service" ) } 
    | ansi strip 
    | skip 1 
    | drop nth 1 
    | str join (char nl) 
    | detect columns --guess 
}
if (not $windows) {
    # hide "services list"
}

def "services start" [name: string] {
    if ($name | is-empty) {
        error make {msg: "service name cannot be empty"}
    }
    pwsh -c $"Start-Service -Name '($name)'" 
}


def "services stop" [name: string] {
    if ($name | is-empty) {
        error make {msg: "service name cannot be empty"}
    }
    pwsh -c $"Stop-Service -Name '($name)'" 
}




# let nrb_path = $"path:($flake_path)#($host)"


# ----------------------------------------------------------
#  Config Setup
# ----------------------------------------------------------

def edit [path: path] {
    ^($env.config.buffer_editor | default $env.VISUAL | default $env.EDITOR) $path
}

alias "core config nu" = config nu
def "config nu" [
    --local(-l) # Open the local config file (`$nu.config-path`) instead of the `$flake_path/files/config.nu`
    --doc(-s) # Print a commented `config.nu` with documentation instead.
    --default(-d) # Print the internal default `config.nu` file instead
] {
    if $doc {
        core config nu --doc
    } else if $default {
        core config nu --default 
    } else if $local { core config nu } else {
        edit $"($flake_path)/files/config.nu"
    }
}

def "config helix" [] { edit ~/.config/helix/config.toml }

alias "config hx" = config helix

def "config niri" [] { edit ~/.config/niri/config.kdl }

def "config waybar" [] { edit ~/.config/waybar/ }

def "config mako" [] { edit ~/.config/mako/config  } 

# -----------------------------------------------------------
#  WSL environment setup
# -----------------------------------------------------------

if $wsl and ("/tmp/ssh-agent-sock.txt" | path exists) {
    let ssh_agent_sock = (open /tmp/ssh-agent-sock.txt | str trim)
    if ($ssh_agent_sock != "") {
        $env.SSH_AUTH_SOCK = $ssh_agent_sock
        print $"using ssh agent socket: ($ssh_agent_sock)"
    } else {
        print "warning: ssh agent socket is empty, not setting SSH_AUTH_SOCK"
    }
}


# -----------------------------------------------------------
# Path setup
# -----------------------------------------------------------

use std "path add"
path add ~/.deno/bin
path add ~/.local/bin

# -----------------------------------------------------------
#  Aliases
# -----------------------------------------------------------

alias gi = git init
alias grao = git remote add origin
alias ga = git add -A .
alias gc = git commit -S -a -m
alias gf = git fetch
alias gch = git checkout
alias gbr = git branch
alias gm = git merge
alias gpu = git push
alias gpl = git pull
alias g = git

alias wg = winget
alias wgi = winget install
alias wgs = winget search

# alias nixos = sudo nixos-rebuild switch --flake path:($env.ENIX_FLAKE_PATH)#($host)
alias snrb = sudo nixos-rebuild
alias nrb = nixos-rebuild
alias nrbf = nrb switch --flake 
alias snrbf = snrb switch --flake
alias brctl = brightnessctl

alias cat = open -r
alias grep = rg

alias pw = packwiz

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
    if ($windows) {
        if ($wsl_for_nixos) {
            print "warning: tried to build on windows - using WSL instead"
            wsl run --distro nixos {nixos elder}
        } else {
            print "warning: cannot build nixos on windows (no usable WSL distro found)"
            return
        }
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
let zoxide_completer = {|spans|
    $spans | skip 1 | zoxide query -l ...$in | lines | each {|line| $line | str replace "\\" "/" | str replace $env.HOME '~' } | where {|x| $x != $env.PWD}
}
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }
    $spans | save -f ~/.tmp-spans.nuon

    match $spans.0 {
        # carapace completions are incorrect for nu
        # nu => $fish_completer
        # fish completes commits and branch names in a nicer way
        # git => $fish_completer
        # carapace doesn't have completions for asdf
        # asdf => $fish_completer
        # use zoxide completions for zoxide commands
        # __zoxide_z | __zoxide_zi => $zoxide_completer
        __zoxide_z | __zoxide_zi | z | zi => $zoxide_completer
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
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }
    $spans | save -f ~/.tmp-spans.nuon

    match $spans.0 {
        _ => $carapace_completer
    } | do $in $spans
}
$env.config.completions.external = {
    enable: true,
    completer: $external_completer,
};
