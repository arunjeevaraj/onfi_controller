/*
* Author: Arun Jeevaraj
* Date: Dec 8 2021
* Description: Onfi phy layer supporting SDR. 
*/
`timescale 1ns / 1ps
module onfi_sdr
#(parameter DATA_CHANNEL_WIDTH = 8, DATA_CHANNEL_N = 1, PHY_MODE = 0)
( input clk,
  input rst_n,

  //to NAND FLASH
  output ALE,
  output CE_n,
  output CLE,
  inout[7:0] DATA,
  output RE_n,
  output WE_n,
  output WP_n,
  input Ready,

  // to onfi_ctrl
  input start_phy, 


  output done
);

reg[DATA_WIDTH-1:0] memory_sram[0:2**ADDR_WIDTH-1];

wire[DATA_WIDTH-1:0] data_write, data_read;

assign data_write = mem_wen ? mem_wdata : memory_sram[mem_addr];
assign data_read = mem_ren ? memory_sram[mem_addr] : 'b0;

always @(posedge clk) begin
    memory_sram[mem_addr] <= data_write;
    mem_rdata <= data_read;
end

endmodule