/*
* Author: Arun Jeevaraj
* Date: Dec 8 2021
* Description: Onfi phy layer supporting SDR. The phy is designed to run at 100 Mhz.
*/
`timescale 1ns / 1ps
module onfi_phy
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

  // to/from onfi_ctrl
  input phy_cmd_in_valid,
  input[31:0] phy_cmd_in,
  output reg [31:0] phy_cmd_status,
  output phy_cmd_status_valid
);


localparam ST_IDLE = 0,
           ST_START_PHY_SCAN = 1,
           ST_FETCH_PARAMETER_PAGE = 2,
           ST_PHY_NIL = 3, // phy not found.
           ST_PAUSE_DATA_TRANSFER = 4,
           ST_COMMAND_LATCH = 5,
           ST_WP_TOGGLE = 6,
           ST_GO_STANDBY = 7,    // phy goes to standy
           ST_STATUS_UPDATE = 8,
           ST_WAIT_FOR_TIMER = 9,  // timer value set based on SDR TIMING MODE
           ST_WAIT_FOR_READY = 10,
           ST_WAIT_FOR_READY_LOW = 11,
           ST_WAIT_FOR_READY_HIGH = 12,
           ST_PHY_RESET = 13,
           ST_PHY_READ_ID = 14; // toggles the write protect mode.  

localparam SDR_TIM_MODE_0 = 0,
           SDR_TIM_MODE_1 = 1,
           SDR_TIM_MODE_2 = 2,
           SDR_TIM_MODE_3 = 3,
           SDR_TIM_MODE_4 = 4,
           SDR_TIM_MODE_5 = 5 ;

localparam ST_SDR_STANDBY = 0,
           ST_SDR_IDLE = 1,
           ST_SDR_COMMAND = 2,
           ST_SDR_ADDRESS = 3,
           ST_SDR_DATA_IN = 4, // wrt to the flash memory
           ST_SDR_DATA_OUT= 5;

reg[2:0] c_state, n_state;
reg[2:0] c_bus_state, n_bus_state;
reg[2:0] c_sdr_timing_mode, n_sdr_timing_mode;


reg write_protect_enabled;
wire write_protect_enabled_n;

reg [31:0] phy_cmd_status_n; 
reg phy_cmd_status_valid_n;
wire data_out_enabled;
reg[31:0] data_out;


wire [4:0] phy_cmd;
wire [4:0] last_phy_cmd_n;
reg  [4:0] last_phy_cmd;


reg [31:0] timer_cnt;
wire[31:0] timer_cnt_n;


reg ready_ff;

assign last_phy_cmd_n = phy_cmd_in_valid ? phy_cmd : last_phy_cmd; 
assign DATA = data_out_enable ? data_out : 'hz;
assign phy_cmd = phy_cmd_in[4:0];


// signal drive for each bus state.
assign CE_n = c_bus_state == ST_SDR_STANDBY ? 1 : 0;
assign ALE  = c_bus_state == ST_SDR_ADDRESS ? 1 : 0;
assign CLE  = c_bus_state == ST_SDR_COMMAND ? 1 : 0;
//assign RE_n = c_bus_state == ST_SDR_DATA_OUT ? 0 : 1;
//assign WE_n = (c_bus_state == ST_SDR_IDLE || c_bus_state == ST_SDR_DATA_OUT) ? 1 : 0;
assign WP_n = write_protection_enabled == 1 ? 0 : 1;

assign write_protect_enabled_n = (phy_cmd_in_valid == 1 && phy_cmd = ST_WP_TOGGLE) ? !write_protect_enabled : write_protect_enabled;

always @(posedge clk) begin
    if (rst_n) begin
        c_state <= ST_IDLE;
        c_bus_state <= ST_SDR_IDLE;
        c_sdr_timing_mode <= SDR_TIM_MODE_0;
        write_protect_enabled <= 1;
        last_phy_cmd <= 'h1f;
        timer_cnt <= 0;
        ready_ff <= 0;
    end else begin
        c_state <= n_state;
        c_bus_state <= n_bus_state;
        c_sdr_timing_mode <= n_sdr_timing_mode;
        write_protect_enabled <= write_protect_enabled_n;
        last_phy_cmd <= last_phy_cmd_in;
        timer_cnt <= timer_cnt_n;
        ready_ff <= ready;
    end
end


always @(*) begin
    n_state = ST_IDLE;
    n_bus_state = ST_SDR_IDLE;
    phy_cmd_status_valid_n = 0;
    phy_cmd_status_n = phy_cmd_status;
    timer_cnt_n = timer_cnt;
    data_out_enable = 0;
    case (c_state)
        ST_IDLE: begin
            n_bus_state = ST_SDR_IDLE;
            if (phy_cmd_in_valid) begin
                case (phy_cmd)
                    ST_WP_TOGGLE: begin
                        n_state = ST_STATUS_UPDATE; 
                    end 

                    ST_COMMAND_LATCH: begin
                        n_state = ST_COMMAND_LATCH; 
                        n_bus_state = ST_SDR_COMMAND;

                    end

                    ST_PHY_RESET: begin
                        n_state = ST_PHY_RESET;
                        n_bus_state = ST_SDR_COMMAND;
                        data_out = 'hff;
                    end

                    ST_PHY_READ_ID: begin
                        n_state = ST_PHY_READ_ID;
                        n_bus_state = ST_SDR_COMMAND;
                    end

                    default: 
                endcase
            end
        end 
        ST_START_PHY_SCAN: begin
            n_state = ST_IDLE;
        end
        ST_COMMAND_LATCH: begin
            
        end

        ST_PHY_RESET: begin
            data_out_enable = 1;
            n_state = ST_WAIT_TIMER;
            timer_cnt_n = 100;//tWB;
        end

        ST_WAIT_TIMER: begin
            if (timer_cnt == 0) begin
                n_state = ST_WAIT_FOR_READY_LOW;
            end else begin
               n_state = ST_WAIT_TIMER; 
            end
        end
    
        ST_WAIT_FOR_READY_LOW: begin
            if (Ready == 0) begin
                n_state = ST_WAIT_FOR_READY_HIGH;
            end
            n_state = ST_WAIT_FOR_READY_LOW;
        end

        ST_WAIT_FOR_READY_HIGH: begin
            if (Ready == 1) begin
                n_state = ST_STATUS_UPDATE;
            end
            n_state = ST_WAIT_FOR_READY_HIGH;
        end

        ST_STATUS_UPDATE: begin
            n_state = ST_IDLE;
            phy_cmd_status_n = {27{0}, last_phy_cmd, write_protection_enabled};
            phy_cmd_status_valid_n = 1;
        end
        default: begin
            
        end 
    endcase
end

endmodule