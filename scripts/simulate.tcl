source ../build/target.tcl

# Read Verilog source files
#if {[string trim ${RTL}] ne ""} {
#  exec xsim ${RTL}
#}

add_wave {/onfi_tb /onfi_tb/o1/onfi_reg_control}
run 100ns
