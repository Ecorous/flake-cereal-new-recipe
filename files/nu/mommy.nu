$env.MOMMY_CAREGIVER = "mommy"
$env.MOMMY_PRONOUNS = ["she" "her" "hers" "herself"]
$env.MOMMY_LITTLE = "girl"
$env.MOMMY_PREFIX = ""
$env.MOMMY_SUFFIX = "~"
$env.MOMMY_CAPITALIZE = false
$env.MOMMY_COMPLIMENTS = [
    # generic~
    "*pats your head*"
    # good X~
    "good $little"
    "good job, my $little"
    "that's a good $little"
    "who's my good $little"
    # proud~
    "$caregiver is very proud of you"
    "$caregiver is so proud of you"
    "$caregiver knew you could do it"
    "$caregiver loves you, you are doing amazing"
    # compliment~
    "$caregiver's $little is so smart"
    # reward~
    "$caregiver thinks you deserve a special treat for that"
    "my little $little deserves a big fat kiss for that"
]
$env.MOMMY_COMPLIMENTS_EXTRA = []
$env.MOMMY_COMPLIMENTS_ENABLED = true
$env.MOMMY_ENCOURAGEMENTS = [
    # trust~
    "$caregiver believes in you"
    "$caregiver knows you'll get there"
    "$caregiver knows $their little $little can do better"
    "just know that $caregiver still loves you"
    "$caregiver knows you're doing your best"
    # consolation~
    "don't worry, it'll be alright"
    "it's okay to make mistakes"
    "$caregiver knows it's hard, but it will be okay"
    # fallback~
    "$caregiver is always here for you"
    "$caregiver is always here for you if you need $them"
    "come here, sit on my lap while we figure this out together"
    # encouragement~
    "never give up, my love"
    "just a little further, $caregiver knows you can do it"
    "$caregiver knows you'll get there, don't worry about it"

    # clean up~
    "did $caregiver's $little make a big mess"
]
$env.MOMMY_ENCOURAGEMENTS_EXTRA = []
$env.MOMMY_ENCOURAGEMENTS_ENABLED = true
$env.MOMMY_IGNORED_STATUS_CODES = [138]
$env.MOMMY_COLOUR = (ansi plum2)


let mommy: record = {
    caregiver: $env.MOMMY_CAREGIVER,
    pronouns: $env.MOMMY_PRONOUNS,
    little: $env.MOMMY_LITTLE,
    prefix: $env.MOMMY_PREFIX,
    suffix: $env.MOMMY_SUFFIX,
    capitalize: $env.MOMMY_CAPITALIZE,
    compliments: $env.MOMMY_COMPLIMENTS,
    compliments_extra: $env.MOMMY_COMPLIMENTS_EXTRA,
    compliments_enabled: $env.MOMMY_COMPLIMENTS_ENABLED,
    encouragements: $env.MOMMY_ENCOURAGEMENTS,
    encouragements_extra: $env.MOMMY_ENCOURAGEMENTS_EXTRA,
    encouragements_enabled: $env.MOMMY_ENCOURAGEMENTS_ENABLED,
    ignored_status_codes: $env.MOMMY_IGNORED_STATUS_CODES,
    colour: $env.MOMMY_COLOUR,
}

def mommy_util_capitalize [text: string] {
    if $mommy.capitalize {
        return $text
            | str capitalize
    } else {
        return $text
    }
}



def "mommy replace" [template: string] {
    $template
        | str replace --all "$caregiver" $mommy.caregiver
        | str replace --all "$they" $mommy.pronouns.0
        | str replace --all "$them" $mommy.pronouns.1
        | str replace --all "$their" $mommy.pronouns.1
        | str replace --all "$theirs" $mommy.pronouns.2
        | str replace --all "$themself" $mommy.pronouns.3
        | str replace --all "$little" $mommy.little
        | str replace --all "$n" "\n"
        | str replace --all "$s" "/"
        | str replace --all "$_" " "
        | mommy_util_capitalize $in
}

def mommy_util_format [text: string] {
    $mommy.colour + $mommy.prefix + $text + $mommy.suffix + (ansi reset)
}

def mommy_util_choose [ l: list<string> ] {
    if ($l | length) == 0 {
        ""
    } else {
        $l | shuffle | first
    }
}

def mommy [status_code: int] {
    if ("~/.mommy" | path exists) {
        let v = open ~/.mommy
        if ($v in ["1", "true"]) {

        } else {
            return
        }
    } else {
        "true" | save -f ~/.mommy
    }
    if $status_code in $mommy.ignored_status_codes {
        $env.LAST_EXIT_CODE = $status_code
        return 
    }
    let final_compliments = $mommy.compliments | append $mommy.compliments_extra | each {|x| mommy replace $x } 
    let final_encouragements = $mommy.encouragements | append $mommy.encouragements_extra | each {|x| mommy replace $x}
    if ($status_code == 0) {
        if $mommy.compliments_enabled {
            let compliment = ( mommy_util_choose $final_compliments ) 
            return ( mommy_util_format $compliment )
        }
    } else {
        if $mommy.encouragements_enabled {
            let encouragement = (mommy_util_choose $final_encouragements)
            return ( mommy_util_format $encouragement )
        }
    }
} 

def "mommy toggle" [] {
    if ("~/.mommy" | path exists) {
        let v = open ~/.mommy
        if ($v in ["1", "true"]) {
            "false" | save -f ~/.mommy
            print "mommy is now disabled~"
        } else {
            "true" | save -f ~/.mommy
            print "mommy is now enabled~"
        }
    } else {
        "true" | save -f ~/.mommy
        echo "mommy is now enabled~"
    }
}

def "mommy say" [text: string] {
    print ( mommy replace $text | mommy_util_format $in )
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
        if $format {mommy_util_format $x} else $x |
        if $replace {mommy replace $in} else $in  
    }
}
def "mommy encouragements" [--format=true --replace=true] {
    if not $mommy.encouragements_enabled {
        mommy say "warning: $caregiver's encouragements are currently disabled"
    }
    $mommy.encouragements | each {|x| 
        if $format {mommy_util_format $x} else $x |
        if $replace {mommy replace $in} else $in  
    }

}

$env.PROMPT_COMMAND_RIGHT = {|| mommy $env.LAST_EXIT_CODE }