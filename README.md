# onfi_controller
Summary to be added


## Architecture
Architecture details to be added



## Host interface support
Host interface supported to be added




## Nand Media Phy support
Nand Media physical layers supported to be added




## Make commands to run.
- `make lint` - runs lint tool with verilator
- `make sim_vivado/onfi_tb.v` - creates the simulation snapshot, compiles the verilog sources and run the simulation in vivado with waveform. 
All signals at the top level are already added.
- `make  sim/onfi_tb.fst` 
runs the simulations with icarus Verilog, and dumps the waveform file as onfi_tb.fst. You can use GTKwave to view the waveform.
