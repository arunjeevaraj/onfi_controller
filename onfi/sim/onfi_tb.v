`timescale 1ns/1ps

module onfi_tb();

reg[3:0] sw;
wire[3:0] led;
reg clk = 1'b0;

always begin
	clk <= !clk;
       	#3;
end


onfi_top o1 (
	.sysclk(clk),
       	.sw(sw),
       	.led(led)
	);


initial begin
  `ifdef IVERILOG
      $dumpfile("onfi_testbench.fst");
      $dumpvars(0, onfi_tb);
  `endif
	$display("simulation started \n");
        sw <= 4'hf;
	#10;
	sw <= 4'ha;
	#20
	sw <= 4'h0;
	#60
	$finish();
end



endmodule

