`timescale 1ns / 1ps

module onfi_top #(parameter MM_DATA_W = 32, MM_ADDR_W = 8)
(
  input sysclk,
  input [3:0] sw,
  output [3:0] led,


  //mm wishbone interface
  input mm_clk_i,           // wishbone interface clock
  input mm_rst_i,           // wishbone interface reset.

  input mm_cyc_i,           // bus valid cycle
  input mm_stb_i,           // data ready

  input[MM_ADDR_W - 1:0] mm_addr_i, // address
  input[MM_DATA_W - 1:0] mm_dat_i,  // data_written in
  output[MM_DATA_W - 1:0] mm_dat_o,  // data_read out

  input mm_we_i,             // write enable
  output mm_ack_o,          // termination to the data
  output mm_err_o
);

wire[32-1:0] control_out;

onfi_reg  #(MM_DATA_W, MM_ADDR_W) onfi_reg_control
(  .mm_clk_i(mm_clk_i),           // wishbone interface clock
   .mm_rst_i(mm_rst_i),           // wishbone interface reset.
   .mm_cyc_i(mm_cyc_i),           // bus valid cycle
   .mm_stb_i(mm_stb_i),           // data ready
   .mm_addr_i(mm_addr_i), // address
   .mm_dat_i(mm_dat_i),  // data_written in
   .mm_dat_o(mm_dat_o),  // data_read out
   .mm_we_i(mm_we_i),             // write enable
   .mm_ack_o(mm_ack_o),          // termination to the data
   .mm_err_o(mm_err_o),
  .control_out(control_out)
  );


reg [3:0] prev_sw;
//reg [3:0] out_led;




always@(posedge sysclk) begin
  prev_sw <= sw;
end

assign led = (prev_sw) & (~sw);

endmodule
