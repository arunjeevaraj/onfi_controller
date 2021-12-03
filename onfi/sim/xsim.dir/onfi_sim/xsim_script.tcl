set_param project.enableReportConfiguration 0
load_feature core
current_fileset
xsim {onfi_sim} -autoloadwcfg -tclbatch {/home/arun/Documents/xilinx/Fpga_repo/onfi/../scripts/simulate.tcl}
