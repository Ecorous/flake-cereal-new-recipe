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