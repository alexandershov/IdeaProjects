# everything is a command in tcl, there's no assignment operator, set is a command
# format is <command name> <arg 1> <arg 2> ...
# command and arguments are separated by spaces
# you don't need quoting
set x 66
puts $x

# [some command] performs command substitution, it replaces [some command] by the command result
# set x returns the current value of x
puts [set x]

# actually $x is redundant, you can you [set x], but's more verbose
# $x is variable substitution

# to have arguments/strings with spaces you can you two types of grouping
# first one is double quotes
# variables are expanded inside of double quotes
puts "x = $x"

# another one is verbatim quoting, nothing is expanded, this prints "{x = $x}" verbatim
puts {x = $x}

# everything is a command in tcl
# `if` is a command, it takes two arguments: condition and body (string)
# `if` evals the second argument!
if "$x == 66" {
    puts {[inside of if] x is 66!}
}

# tcl is super late-binding, everything is a string
set part_1 pu
set part_2 ts
# $part_1$part_2 is concatenated into `puts` and puts is getting executed
$part_1$part_2 "concatenation works everywhere!"

# tcl has lists (as a matter of fact you can think of tcl commands as lists)
set my_list [list x y z "first second"]
puts $my_list

# expr can evaluate math expressions
puts "expr value = [expr 3 + $x]"

# if/while actually use [expr ...] to evaluate its body
# you can implement your own while!
# `uplevel 1 string` evals a string in a parent stack frame
# all of it is like lisp macros but based on strings
proc my_while {test body} {
    for {} {[uplevel 1 [list expr $test]]} {} {
        uplevel 1 $body
    }
}

set i 0
my_while {$i < 3} {
    puts "i = $i"
    incr i
}

# also, there's no nil in tcl!

package require Tk

# tk is a graphics toolkit

label .msg -text "Hello, Tcl/Tk!"
button .btn -text "Click Me" -command {
    .msg configure -text "Button clicked!"
}

pack .msg -padx 20 -pady 10
pack .btn -padx 20 -pady 10

wm title . "Simple Tcl/Tk App"


# tcl comes with the event loop and simple way to do socket programming
# here's async network application in 7 lines of code (you can connect to it with `nc localhost 9999`)
socket -server handler 9999
proc handler {fd clientaddr clientport} {
    set t [clock format [clock seconds]]
    puts $fd "Hello $clientaddr:$clientport, current date is $t"
    close $fd
}
vwait forever
