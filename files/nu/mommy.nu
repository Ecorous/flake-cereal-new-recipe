if (not (("~/.mommy.nuon" | path exists) and ("~/.mommy.nuon" | path type | $in == "file"))) {
    mommy reset
} 
let mommy: record = (open ~/.mommy.nuon)

def mommy_util_capitalize [text: string] {
    if (mommy get capitalize) {$text | str capitalize} else $text
}

let mommy_templates = [
    {template: "caregiver", value: (mommy get caregiver)},
    {template: "they", value: (mommy get pronouns).0},
    {template: "them", value: (mommy get pronouns).1},
    {template: "their", value: (mommy get pronouns).1},
    {template: "theirs", value: (mommy get pronouns).2},
    {template: "themself", value: (mommy get pronouns).3},
    {template: "little", value: (mommy get little)},
    {template: "n", value: "\n"},
    {template: "s", value: "/"},
    {template: "_", value: " "},
]

const mommy_defaults = {
    caregiver: "mommy",
    pronouns: ["she", "her", "hers", "herself"],
    little: "girl",
    prefix: "",
    suffix: "~",
    capitalize: false,
    startup_messages_enabled: true,
    startup_messages: [
        "hai little $little",
        "is $caregiver's little $little ready for some fun?"
        "time for $caregiver to sit down with you and work it out together"
        "$caregiver's here to help"
        "$caregiver loves you"
        "ready to get stuff done, little $little?"
        "*sits you on my lap* time get some work done, $caregiver's here"
        "$caregiver's here for $their little $little",
        "what are we working on today, little $little?",
        "*pets your head* hello again, little $little"
    ],
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
} 

def "mommy replace" [template: string] {
    $mommy_templates | reduce -f $template { |t| str replace --all ("$" + $t.template) $t.value } | mommy_util_capitalize $in
}

def "mommy format" [text: string] {
    $"(mommy get colour)(mommy get prefix)($text)(mommy get suffix)(ansi reset)"
}

def mommy [status_code: int] {
    if not (mommy get enabled) { return }

    if $status_code in (mommy get ignored_status_codes) {
        $env.LAST_EXIT_CODE = $status_code
        return 
    }
    if ($status_code == 0) {
        if (mommy get compliments_enabled) {
            return ( mommy format (mommy get compliments | shuffle | first | mommy replace $in) )
        }
    } else {
        if (mommy get encouragements_enabled) {
            return ( mommy format (mommy get encouragements | shuffle | first | mommy replace $in) )
        }
    }
} 

def "mommy set enabled" [enabled: bool, --say=true] {
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
    mommy set enabled (not (mommy get enabled)) --say true
}

def "mommy say" [text: string, --no-newline(-n)] {
    if ($no_newline) {
        print -n (mommy replace $text | mommy format $in)
    } else {
        print (mommy replace $text | mommy format $in)
    }
} 

def "mommy help" [] {
    mommy say "don't worry, $caregiver is here to help you"
    help mommy
}

def "mommy compliments" [--format=true --replace=true] {
    if not (mommy get compliments_enabled) {
        mommy say "warning: $caregiver's compliments are currently disabled"
    }

    mommy get compliments | each {|x| 
        if $format {mommy format $x} else $x |
        if $replace {mommy replace $in} else $in  
    }
}
def "mommy encouragements" [--format=true --replace=true] {
    if not (mommy get encouragements_enabled) {
        mommy say "warning: $caregiver's encouragements are currently disabled"
    }
    mommy get encouragements | each {|x| 
        if $format {mommy format $x} else $x |
        if $replace {mommy replace $in} else $in  
    }
}


def "mommy keys" [] {
    $mommy_defaults | columns
}

def "mommy completions set" [context: string] {
    let k = $context | split words | last
    [] | if ($k in $mommy_defaults) { append ($mommy_defaults | get $k)} | if ($k in $mommy) { prepend ($mommy | get $k)}
}

def "mommy set" [ key: string@"mommy keys", value: any@"mommy completions set" ] {
    if ($key in $mommy_defaults) {
        mommy save { upsert $key $value }        
    } else {
        error make {
            msg: "key does not exist",
            labels: [{
                text: $"key ($key) does not exist",
                span: (metadata $key).span
            }]
        }
    }
}

def "mommy save" [modifier: closure] {
    $mommy | do $modifier | to nuon --indent 4 | save -f ~/.mommy.nuon
}

def "mommy add compliment" [value: string] { mommy save { upsert compliments (mommy get compliments | append $value)} }
def "mommy add encouragement" [value: string] { mommy save {upsert encouragements (mommy get encouragements | append $value)} }


def "mommy get enabled" [] {
    if ("~/.mommy" | path exists) {
        return ((open ~/.mommy) in ["1", "true"])
    } else {
        mommy set enabled true --say false
        return true
    }
}

def "mommy startup" [] {
    mommy say (mommy get startup_messages | shuffle | first | str trim) -n
}

def "mommy get" [ key: string@"mommy keys" ] {
    let mommy = open ~/.mommy.nuon
    if ($key in $mommy) {
        $mommy | get $key
    } else if ($key in $mommy_defaults) {
        mommy save { insert $key ($mommy_defaults | get $key) }
        $mommy_defaults | get $key
    } else {
        error make {
            msg: "key does not exist",
            labels: [{
                text: $"key ($key) does not exist",
                span: (metadata $key).span
            }]
        }
    }
}

def "mommy reset" [] {
    if ("~/.mommy.nuon" | path exists) {
        mommy say "warning: ~/.mommy.nuon already exists, moving to ~/.mommy.nuon.bak"
        mv ~/.mommy.nuon ~/.mommy.nuon.bak
    }
    mommy save { $mommy_defaults }
}

if (mommy get startup_messages_enabled) { mommy startup }
$env.PROMPT_COMMAND_RIGHT = {|| mommy $env.LAST_EXIT_CODE }
