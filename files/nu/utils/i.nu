# nix-like inherit "statement"
@example "Inherit variables in scope into a record" {
    let foo = "FOO"
    let bar = "BAR"
    {...(inherit $foo $bar) baz: "BAZ"}
} --result {foo: "FOO" bar: "BAR" baz: "BAZ"}
@category utility
@search-terms record variable inherit
export def inherit [...rest: any] {
    $rest
    | each {|e|
        metadata
        | view span $in.span.start $in.span.end
        | str trim --left --char '$'
        | {($in): $e}
    }
    | into record
}
