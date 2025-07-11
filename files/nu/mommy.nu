if (not (("~/.mommy.nuon" | path exists) and ("~/.mommy.nuon" | path type | $in == "file"))) {
    mommy defaults
} 
let mommy: record = (open ~/.mommy.nuon)

def mommy_util_capitalize [text: string] {
    if $mommy.capitalize {
        return $text
            | str capitalize
    } else {
        return $text
    }
}

let mommy_templates = [
    {template: "caregiver", value: $mommy.caregiver},
    {template: "they", value: $mommy.pronouns.0},
    {template: "them", value: $mommy.pronouns.1},
    {template: "their", value: $mommy.pronouns.1},
    {template: "theirs", value: $mommy.pronouns.2},
    {template: "themself", value: $mommy.pronouns.3},
    {template: "little", value: $mommy.little},
    {template: "n", value: "\n"},
    {template: "s", value: "/"},
    {template: "_", value: " "},
]


def "mommy replace" [template: string] {
    $mommy_templates | reduce -f $template { |t| str replace --all ("$" + $t.template) $t.value } | mommy_util_capitalize $in
}

def "mommy format" [text: string] {
    $mommy.colour + $mommy.prefix + $text + $mommy.suffix + (ansi reset)
}

def mommy [status_code: int] {
    if not (mommy get enabled) {
        return
    }

    if $status_code in $mommy.ignored_status_codes {
        $env.LAST_EXIT_CODE = $status_code
        return 
    }
    if ($status_code == 0) {
        if $mommy.compliments_enabled {
            return ( mommy format ($mommy.compliments | shuffle | first | mommy replace $in) )
        }
    } else {
        if $mommy.encouragements_enabled {
            return ( mommy format ($mommy.encouragements | shuffle | first | mommy replace $in) )
        }
    }
} 

def "mommy set" [enabled: bool, --say=true] {
    $enabled | save -f ~/.mommy
    if ($say) {
        if $enabled {
            mommy say "$caregiver is now enabled"
        } else {
            mommy say "$caregiver is now disabled"
        }
    }
}

def "mommy toggle" [] {
    mommy set (not (mommy get enabled)) --say true
}

def "mommy say" [text: string] {
    print ( mommy replace $text | mommy format $in )
} 

def "mommy help" [] {
    mommy say "don't worry, $caregiver is here to help you"
    help mommy
}

def "mommy compliments" [--format=true --replace=true] {
    if not $mommy.compliments_enabled {
        mommy say "warning: $caregiver's compliments are currently disabled"
    }

    $mommy.compliments | each {|x| 
        if $format {mommy format $x} else $x |
        if $replace {mommy replace $in} else $in  
    }
}
def "mommy encouragements" [--format=true --replace=true] {
    if not $mommy.encouragements_enabled {
        mommy say "warning: $caregiver's encouragements are currently disabled"
    }
    $mommy.encouragements | each {|x| 
        if $format {mommy format $x} else $x |
        if $replace {mommy replace $in} else $in  
    }
}

def "mommy set enabled" [ value: bool ] {
    mommy set $value --say false
    if $value {
        mommy say "$caregiver is now enabled"
    } else {
        mommy say "$caregiver is now disabled"
    }
}

def "mommy set caregiver" [value: string] { $mommy | upsert caregiver $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set pronouns" [value: list<string>] { $mommy | upsert pronouns $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set little" [value: string] { $mommy | upsert little $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set prefix" [value: string] { $mommy | upsert prefix $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set suffix" [value: string] { $mommy | upsert suffix $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set capitalize" [value: bool] { $mommy | upsert capitalize $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set compliments" [value: list<string>] { $mommy | upsert compliments ($value | append $mommy.compliments) | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set compliments enabled" [value: bool] { $mommy | upsert compliments_enabled $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set encouragements" [value: list<string>] { $mommy | upsert encouragements ($value | append $mommy.encouragements) | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set encouragements enabled" [value: bool] { $mommy | upsert encouragements_enabled $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set ignored status codes" [value: list<int>] { $mommy | upsert ignored_status_codes $value | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy set colour" [value: string] { $mommy | upsert colour $value | to nuon --indent 4 | save -f ~/.mommy.nuon }


def "mommy add compliment" [value: string] { $mommy | upsert compliments ($mommy.compliments | append $value) | to nuon --indent 4 | save -f ~/.mommy.nuon }
def "mommy add encouragement" [value: string] { $mommy | upsert encouragements ($mommy.encouragements | append $value) | to nuon --indent 4 | save -f ~/.mommy.nuon }


def "mommy get enabled" [] {
    if ("~/.mommy" | path exists) {
        return ((open ~/.mommy) in ["1", "true"])
    } else {
        mommy set true --say false
        return true
    }
}

def "mommy get caregiver" [] { $mommy.caregiver }
def "mommy get pronouns" [] { $mommy.pronouns }
def "mommy get little" [] { $mommy.little }
def "mommy get prefix" [] { $mommy.prefix }
def "mommy get suffix" [] { $mommy.suffix }
def "mommy get capitalize" [] { $mommy.capitalize }
def "mommy get compliments" [] { $mommy.compliments }
def "mommy get compliments enabled" [] { $mommy.compliments_enabled }
def "mommy get encouragements" [] { $mommy.encouragements }
def "mommy get encouragements enabled" [] { $mommy.encouragements_enabled }
def "mommy get ignored status codes" [] { $mommy.ignored_status_codes }
def "mommy get colour" [] { $mommy.colour }

def "mommy defaults" [] {
    if ("~/.mommy.nuon" | path exists) {
        mommy say "warning: ~/.mommy.nuon already exists, moving to ~/.mommy.nuon.bak"
        mv ~/.mommy.nuon ~/.mommy.nuon.bak
    }
    {
        caregiver: "mommy",
        pronouns: ["she", "her", "hers", "herself"],
        little: "girl",
        prefix: "",
        suffix: "~",
        capitalize: false,
        compliments: [
            # generic~
            "*pats your head*",
            # good X~
            "good $little",
            "good job, my $little",
            "that's a good $little",
            "who's my good $little",
            # proud~
            "$caregiver is very proud of you",
            "$caregiver is so proud of you",
            "$caregiver knew you could do it",
            "$caregiver loves you, you are doing amazing",
            # compliment~
            "$caregiver's $little is so smart",
            # reward~
            "$caregiver thinks you deserve a special treat for that",
            "my little $little deserves a big fat kiss for that"
        ],
        compliments_enabled: true,
        encouragements: [
            # trust~
            "$caregiver believes in you",
            "$caregiver knows you'll get there",
            "$caregiver knows $their little $little can do better",
            "just know that $caregiver still loves you",
            "$caregiver knows you're doing your best",
            # consolation~
            "don't worry, it'll be alright",
            "it's okay to make mistakes",
            "$caregiver knows it's hard, but it will be okay",
            # fallback~
            "$caregiver is always here for you",
            "$caregiver is always here for you if you need $them",
            "come here, sit on my lap while we figure this out together",
            # encouragement~
            "never give up, my love",
            "just a little further, $caregiver knows you can do it",
            "$caregiver knows you'll get there, don't worry about it",

            # clean up~
            "did $caregiver's $little make a big mess"
        ],
        encouragements_enabled: true,
        ignored_status_codes: [138],
        colour: (ansi plum2)
    } | to nuon --indent 4 | save -f ~/.mommy.nuon
}

$env.PROMPT_COMMAND_RIGHT = {|| mommy $env.LAST_EXIT_CODE }