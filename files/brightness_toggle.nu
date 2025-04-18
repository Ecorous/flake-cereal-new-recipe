#!/usr/bin/env nu

alias brctl = brightnessctl

let current_value = brctl get

let tmp_file = "/tmp/brightness_value.txt"

if $current_value == 0 {
    try {
        let tmp_value = ( $tmp_file | open -r );
        if $tmp_value != 0 {
            brctl set $tmp_value
        } else {
            brctl set 1
        }
    } catch {
        brctl set 1
    }
} else {
    $current_value | save -f $tmp_file
    brctl set 0
}