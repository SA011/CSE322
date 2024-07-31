set ns [new Simulator]

set val(chan)                   Channel/WirelessChannel
set val(prop)                   Propagation/TwoRayGround
set val(ant)                    Antenna/OmniAntenna
set val(ll)                     LL
set val(ifq)                    Queue/DropTail/PriQueue
set val(ifqlen)                 50
set val(netif)                  Phy/WirelessPhy/802_15_4
set val(mac)                    Mac/802_15_4
set val(rp)                     DSDV
set val(rate)                   5
set val(node_size)              12

set val(area)                   [lindex $argv 0]  
set val(nn)                     [lindex $argv 1]  
set val(nf)                     [lindex $argv 2]  

set trace_file                  [open trace.tr w]
$ns trace-all                   $trace_file

set nam_file                    [open animation.nam w]
$ns namtrace-all-wireless       $nam_file $val(area) $val(area)

set topo                        [new Topography]
$topo load_flatgrid             $val(area) $val(area)

create-god $val(nn)

$ns node-config                 -adhocRouting  $val(rp)          \
                                -llType        $val(ll)          \
                                -macType       $val(mac)         \
                                -ifqType       $val(ifq)         \
                                -ifqLen        $val(ifqlen)      \
                                -antType       $val(ant)         \
                                -propType      $val(prop)        \
                                -phyType       $val(netif)       \
                                -topoInstance  $topo             \
                                -channelType   $val(chan)        \
                                -agentTrace    ON                \
                                -routerTrace   ON                \
                                -macTrace      OFF               \
                                -movementTrace OFF

proc myrand {low high} {
    set rng [expr ($high - $low + 1)]
    return [expr (int(rand() * $rng) + $low)]
}
set duplicate {}
# set val(area) [expr ( $val(area) - $val(rate))]
for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0
    set temp {-1,-1}
    while {1} {
        set tempX [myrand 1 [expr ($val(area) - 1)]]
        set tempY [myrand 1 [expr ($val(area) - 1)]]
        set temp "$tempX $tempY"
        # puts [lsearch -exact $temp]
        # if {[lsearch -exact $temp] == -1} {
            break
        # }
        # puts "DUP"
    }
    # puts [lindex $temp 0]
    # set duplicate [lappend duplicate $temp]
    $node($i) set X_ [lindex $temp 0]
    $node($i) set Y_ [lindex $temp 1]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) $val(node_size)
} 

for {set i 0} {$i < $val(nn)} {incr i} {

    set Time      [myrand 10 30] 
    set temp {-1,-1}
    while {1} {
        set tempX [myrand 1 [expr ($val(area) - 1)]]
        set tempY [myrand 1 [expr ($val(area) - 1)]]
        set temp "$tempX $tempY"
        # puts [lsearch -exact $temp]
        # if {[lsearch -exact $temp] == -1} {
            break
        # }
        # puts "DUP"
    }
    set setZ      [myrand 1 $val(rate)]

    $ns at $Time "$node($i) setdest [lindex $temp 0] [lindex $temp 1] $setZ"

}


set dest [myrand 0 [expr ($val(nn) - 1)]]
puts     "Destination $dest"

for {set i 0} {$i < $val(nf)} {incr i} {

    set src -1

    while {$dest == [set src [myrand 0 [expr ($val(nn) - 1)]]]} {
        
    }

    set udp     [new Agent/UDP]
    set null    [new Agent/Null]
    set cbr     [new Application/Traffic/CBR]

    $ns attach-agent $node($src) $udp
    $ns attach-agent $node($dest) $null
    $ns connect $udp $null
    $udp set fid_ $i
    $cbr attach-agent $udp

    $cbr set type_ CBR
    $cbr set packet_size_ 100
    # $cbr set rate_ 10kb
    # $cbr set random_ false

    $ns at 1.0 "$cbr start"
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}

proc finish_simulation {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ends"
    $ns halt
}

$ns at 51.0001 "finish_simulation"
$ns at 50.0002 "halt_simulation"

puts "Simulation starts"
$ns run
