`timescale 1ns / 1ps

module onfi_ctrl #(parameter MM_DATA_W = 32, MM_ADDR_W = 8)
(
  input sysclk_in,
  input rst_n,
  input [31:0] cfg_reg_in,
  output [3:0] led_out,  // for debug
  output[4:0] phy_ctrl_out,
  output[2:0] c_state_out
);

localparam ST_IDLE = 0,
           ST_ENUMERATED = 1,
           ST_SEND_COMMAND_LATCH = 2,
           ST_SEND_ADDRESS_LATCH = 3,
           ST_SEND_DATA_INPUT_LATCH = 4,
           ST_SEND_DATA_OUTPUT_LATCH = 5,
           ST_EDA_DATA_OUT = 6,
           ST_READ_STATUS = 7,
           ST_READ_STATUS_ENHANCED = 8;

reg[2:0] c_state, n_state;

always @(posedge sysclk_in) begin
    if (rst_n) begin
        c_state <= ST_IDLE;
    end else begin
        c_state <= n_state;

    end
end

endmodule