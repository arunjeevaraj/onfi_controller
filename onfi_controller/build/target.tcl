set ABS_TOP                         /home/arun/Documents/xilinx/Fpga_repo/onfi_controller
set TOP                            onfi_top
set FPGA_PART                      xc7z020clg400-1
set_param general.maxThreads       4
set_param general.maxBackupLogs    0
set RTL { /home/arun/Documents/xilinx/Fpga_repo/onfi_controller/src/onfi_phy.v /home/arun/Documents/xilinx/Fpga_repo/onfi_controller/src/onfi_top.v /home/arun/Documents/xilinx/Fpga_repo/onfi_controller/src/onfi_ctrl.v /home/arun/Documents/xilinx/Fpga_repo/onfi_controller/src/onfi_reg.v }
set SIM_RTL { /home/arun/Documents/xilinx/Fpga_repo/onfi_controller/sim/onfi_tb.v }
set CONSTRAINTS { /home/arun/Documents/xilinx/Fpga_repo/onfi_controller/src/onfi_top.xdc }
