set ns [new Simulator]
Queue/RED set thresh_ 10
Queue/RED set thresh_queue_ 100
Queue/RED set maxthresh_queue_ 300
Queue/RED set maxthresh_ 30
Queue/RED set factor 0.005
Queue/RED set avg_packet_size 100
Queue/RED set q_weight_ 0.002
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ true
Queue/RED set mean_pktsize_ 1000
Queue/RED set print true

set val(chan)                   Channel/WirelessChannel
set val(prop)                   Propagation/TwoRayGround
set val(ant)                    Antenna/OmniAntenna
set val(ll)                     LL
set val(ifq)                    Queue/RED
set val(ifqlen)                 1000
set val(netif)                  Phy/WirelessPhy/802_15_4
set val(mac)                    Mac/802_15_4
set val(rp)                     DSDV
set val(speed)                  5
set val(rate)                   30000
set val(node_size)              12
set val(area)                   250  
set val(nn)                     40  
set val(nf)                     40  
set val(shred)                  true
set val(energymodel)            EnergyModel 
set val(Energyamount)           20
set val(rx)                     0.5
set val(tx)                     1.0
set val(idlepwr)                0.0
set val(sleeppower) 		    0.3
set val(transitionpower)        0.2		
set val(transitiontime)         3



if {$argc > 0} {
    set val(nn)                 [lindex $argv 0]      
} 

if {$argc > 1} {
    set val(nf)                 [lindex $argv 1]  
} 
if {$argc > 2} {
    set val(rate)               [lindex $argv 2] 
} 
if {$argc > 3} {
    set val(speed)              [lindex $argv 3]  
} 

if {$argc > 4} {
    set val(shred)              [lindex $argv 4]  
} 

Queue/RED set shred $val(shred)

set trace_file                  [open trace.tr w]
$ns trace-all                   $trace_file

set nam_file                    [open animation.nam w]
$ns namtrace-all-wireless       $nam_file $val(area) $val(area)

set topo                        [new Topography]
$topo load_flatgrid             $val(area) $val(area)

create-god $val(nn)

$ns node-config -adhocRouting     $val(rp)              \
                -llType           $val(ll)              \
                -macType          $val(mac)             \
                -ifqType          $val(ifq)             \
                -ifqLen           $val(ifqlen)          \
                -antType          $val(ant)             \
                -propType         $val(prop)            \
                -phyType          $val(netif)           \
                -topoInstance     $topo                 \
                -channelType      $val(chan)            \
                -agentTrace       ON                    \
                -routerTrace      ON                    \
                -macTrace         OFF                   \
                -movementTrace    OFF                   \
                -energyModel      $val(energymodel)     \
                -initialEnergy    $val(Energyamount)    \
                -rxPower          $val(rx)              \
                -txPower          $val(tx)              \
                -idlePower        $val(idlepwr)         \
                -sleepPower       $val(sleeppower)      \
                -transitionPower  $val(transitionpower) \
                -transitionTime   $val(transitiontime)

proc myrand {low high} {
    set rng [expr ($high - $low + 0.9)]
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

    set Time      [myrand 1 5] 
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
    set setZ      $val(speed)

    $ns at $Time "$node($i) setdest [lindex $temp 0] [lindex $temp 1] $setZ"

}


for {set i 0} {$i < $val(nf)} {incr i} {

    set src -1

    set dest [myrand 0 [expr ($val(nn) - 1)]]
    while {$dest == [set src [myrand 0 [expr ($val(nn) - 1)]]]} {
        
    }
    puts "$src TO $dest"

    set udp     [new Agent/UDP]
    set sink    [new Agent/Null]
    set x 96
    if {$i % 2 == 0} {
        set $x 8
    }
    $ns attach-agent $node($src) $udp
    $ns attach-agent $node($dest) $sink
    $ns connect $udp $sink
    $udp set fid_ $i

    set cbr [new Application/Traffic/CBR]
    $cbr attach-agent $udp
    $cbr set packet_size_ $x
    $cbr set rate_ [expr ($val(rate))] 

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
