def "zerotier networks" [] {
    sudo zerotier-cli listnetworks -j 
    | from json 
    | select id name assignedAddresses dns status type 
    | rename id name addresses 
    | each { { 
        id: $in.id,
        name: $in.name,
        addresses: ($in.addresses | to text),
        dns: ($in.dns | each {|dns| $dns | to text} )
    } }
}

def "zerotier join" [id: string] {
    sudo zerotier-cli join $id
}