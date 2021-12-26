`timescale 1ns / 1ps

module onfi_top #(parameter MM_DATA_W = 32, MM_ADDR_W = 8)
(
  input sysclk,
  input [3:0] sw,
  output [3:0] led,
  input rst_n,

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
  output mm_err_o,

// phy
  //to NAND FLASH
  output ALE,
  output CE_n,
  output CLE,
  inout[7:0] DATA,
  output RE_n,
  output WE_n,
  output WP_n,
  input Ready
);

wire[32-1:0] control_out;
wire[4:0] phy_ctrl_out;
wire[2:0] c_state_out;
reg [3:0] prev_sw;
//reg [3:0] out_led;

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

onfi_ctrl #(MM_DATA_W, MM_ADDR_W) onfi_controller
(
  .sysclk_in(sysclk),
  .rst_n(rst_n),
  .cfg_reg_in(control_out),
  .led_out(led),  // for debug
  .phy_ctrl_out(phy_ctrl_out),
  .c_state_out(c_state_out)
);

 onfi_phy #( MM_DATA_W, MM_ADDR_W, 0) onfi_phy_layer
( 
   .clk(sysclk),
   .rst_n(rst_n),

  //to NAND FLASH
  .ALE(ALE),
  .CE_n(CE_n),
  .CLE(CLE),
  .DATA(DATA),
  .RE_n(RE_n),
  .WE_n(WE_n),
  .WP_n(WP_n),
  .Ready(Ready)

  // to onfi_ctrl
  //start_phy, 
  //done_phy
);

always@(posedge sysclk) begin
  prev_sw <= sw;
end

assign led = (prev_sw) & (~sw);

endmodule
