`timescale 1ns / 1ps

module onfi_top(
  input sysclk,
  input [3:0] sw,
  output [3:0] led
);

reg [3:0] prev_sw;
//reg [3:0] out_led;

always@(posedge sysclk) begin
   prev_sw <= sw;
end

assign led = (prev_sw) & (~sw);

endmodule
