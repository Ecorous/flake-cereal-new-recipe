def portforward [ --local-port(-l): int --remote-address(-r): string --expose(-e)=true --host(-h)="localhost" ] {
    if ($local_port == null) {
        error make {msg: "flag --local-port (-l) is required"}
    }
    if ($remote_address == null) {
        error make {msg: "flag --remote-address (-r) is required"}
    }
    if ($expose) {
        print "notice: exposing this port on all interfaces (this is perfectly normal)"
    }

    let nu_cmd = "nu -c \"print \"proxying... press ctrl+c to exit\"; sleep (999wk * 100)\""
    

    if ($expose) {
        print $"ssh -o 'GatewayPorts=yes' -v -L 0.0.0.0:($local_port):($remote_address) ($host) ($nu_cmd)"
    } else {
        print $"ssh -v -L 127.0.0.1:($local_port):($remote_address) ($host) ($nu_cmd)"
    }
}