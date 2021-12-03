source ../build/target.tcl

# Read Verilog source files
#if {[string trim ${RTL}] ne ""} {
#  exec xsim ${RTL}
#}

add_wave {/onfi_tb}
run -all
