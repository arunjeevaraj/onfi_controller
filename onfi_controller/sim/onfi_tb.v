/*
* Author: Arun Jeevaraj
* Date: Dec 7 2021
* Description: Test bench, Drives the wishbone interface, with single read and write accesses.!  
*/


`timescale 1ns/1ps

module onfi_tb();

reg[3:0] sw;
wire[3:0] led;
reg clk = 1'b0;

localparam MM_DATA_W = 32;
localparam MM_ADDR_W = 8;
localparam DMA_DATA_WIDTH = 8;


//tb master mm wishbone interface
reg mm_clk_o;           // wishbone interface clock
reg mm_rst_o;           // wishbone interface reset.

reg mm_cyc_o;           // bus valid cycle
reg mm_stb_o;           // data ready

reg[MM_ADDR_W - 1:0] mm_addr_o; // address
reg[MM_DATA_W - 1:0] mm_dat_o;  // data_written out
wire[MM_DATA_W - 1:0] mm_dat_i;  // data_read in

reg mm_we_o;             // write enable
wire mm_ack_i;          // termination to the data
wire mm_err_i;

//tb streaming interface for raw data.
reg data_in_valid;  // data going into flash controller.
wire data_in_ready; // data_in ready back pressure
reg[DMA_DATA_WIDTH-1:0] data_in; // data going into the Controller.

wire data_out_valid; // data going out of the flash controller.
wire[DMA_DATA_WIDTH-1:0] data_out; // data going out of the controller.
reg data_out_ready; // test bench back pressure. active high to back pressure.


reg[DMA_DATA_WIDTH-1:0] tb_stream_data_in[0:8*1024];
reg[DMA_DATA_WIDTH-1:0] tb_stream_data_out[0:8*1024];



// write register 
task mm_reg_access;
	input[MM_ADDR_W - 1:0] addr;
	input[MM_DATA_W - 1:0] w_data;
	output[MM_DATA_W - 1:0] r_data;
	input write_enable;
	integer count;
	reg loop;
begin
	$display("Accessing register write data: %h addr: %h\n", w_data, addr);
	@(negedge mm_clk_o && mm_rst_o == 1'b0);  
    mm_cyc_o = 1'b1;
	mm_stb_o = 1'b1;
	mm_addr_o = addr;
	mm_dat_o = w_data;
	mm_we_o = write_enable;
	
	count = 0;
	loop = 1;
	while (loop) begin
		@(posedge mm_clk_o);
		count = count + 1;
		if (count > 5) loop = 0; // break if the controller is stalled.
		if (mm_ack_i == 1'b1) begin
			loop = 0; // successful with the access.
			r_data = write_enable ? mm_dat_i : 32'bx;
		end 
	end
    //@(posedge mm_ack_i or posedge mm_err_i);
	mm_cyc_o = 1'b0;
	mm_stb_o = 1'b0;
	mm_addr_o = 0;
	mm_dat_o = 0;
	mm_we_o = 1'b0;
	$display("Access to register  done, read data: %h \n", mm_dat_i);
	
end
endtask

always begin
	clk <= !clk;
    #3;
end


always @(*) begin
	mm_clk_o <= clk;
end


onfi_top o1 (
	.sysclk(clk),
       	.sw(sw),
       	.led(led),
//mm wishbone interface
   .mm_clk_i(mm_clk_o),           // wishbone interface clock
   .mm_rst_i(mm_rst_o),           // wishbone interface reset.

   .mm_cyc_i(mm_cyc_o),           // bus valid cycle
   .mm_stb_i(mm_stb_o),           // data ready

   .mm_addr_i(mm_addr_o), // address
   .mm_dat_i(mm_dat_o),  // data_written in
   .mm_dat_o(mm_dat_i),  // data_read out

   .mm_we_i(mm_we_o),             // write enable
   .mm_ack_o(mm_ack_i),          // termination to the data
   .mm_err_o(mm_err_i)
);

reg [MM_DATA_W - 1 : 0] read_data_back;

initial begin
  `ifdef IVERILOG
      $dumpfile("onfi_testbench.fst");
      $dumpvars(0, onfi_tb);
  `endif
	$display("simulation started \n");
	mm_rst_o <= 1'b1;
    #10;
	mm_rst_o <= 1'b0;

	// writing to register
	mm_reg_access(8'h4, 32'hc0ffee, read_data_back, 1);
    mm_reg_access(8'h8, 32'habcd, read_data_back, 1);
	mm_reg_access(8'hc, 32'habca, read_data_back, 1);
	mm_reg_access(8'hc, 32'hc0ffee, read_data_back, 1);
	// read the register back.
	mm_reg_access(8'h0, 32'b0, read_data_back, 0);
	$display("Read data : %h ", read_data_back);
	mm_reg_access(8'h4, 32'b0, read_data_back, 0);
	$display("Read data : %h ", read_data_back);
	mm_reg_access(8'h8, 32'b0, read_data_back, 0);
	$display("Read data : %h ", read_data_back);
	mm_reg_access(8'hc, 32'b0, read_data_back, 0);
	$display("Read data : %h ", read_data_back);

        sw <= 4'hf;
	#10;
	sw <= 4'ha;
	#20
	sw <= 4'h0;
	#60
	$display("simulation done \n");
	$finish();
end



endmodule

