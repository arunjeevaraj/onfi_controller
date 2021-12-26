module onfi_reg #(parameter MM_DATA_W = 32, MM_ADDR_W = 8)
(
  //mm wishbone interface
  input mm_clk_i,                   // wishbone interface clock
  input mm_rst_i,                   // wishbone interface reset.

  input mm_cyc_i,                   // bus valid cycle
  input mm_stb_i,                   // data ready

  input[MM_ADDR_W - 1:0] mm_addr_i, // address
  input[MM_DATA_W - 1:0] mm_dat_i,  // data_written in
  output[MM_DATA_W - 1:0] mm_dat_o,  // data_read out

  input mm_we_i,                    // write enable
  output mm_ack_o,                  // termination to the data
  output mm_err_o,

  output[32-1:0] control_out
);

// mm_wishbone handler.

localparam[2:0] state_idle = 3'b000,
                state_valid = 3'b001,
                state_error = 3'b011 ;
reg[2:0] c_state;
reg[2:0] n_state;

reg[32-1:0] test_reg;
reg[32-1:0] status_reg;
reg[32-1:0] command_reg;
reg[32-1:0] test_reg_w;
reg[32-1:0] status_reg_w;
reg[32-1:0] command_reg_w;

wire valid_mm_rqst;
reg[MM_ADDR_W-1:0] addr_mm_rqst;
reg[MM_DATA_W-1:0] data_mm_rqst;
reg[MM_DATA_W-1:0] data_read;

assign valid_mm_rqst = mm_cyc_i && mm_stb_i ? 1'b1 : 0;

always @(posedge mm_clk_i) begin
  if (mm_rst_i == 1'b1)  begin// active reset
    //addr_mm_rqst <= 8'b0;
    //data_mm_rqst <= 32'b0;
    c_state      <= state_idle;
    test_reg     <= 32'b0;
    status_reg   <= 32'b0;
    command_reg  <= 32'b0;
  end else begin
    //addr_mm_rqst <= mm_addr_i;
    //data_mm_rqst <= mm_dat_i;
    c_state      <= n_state;
    test_reg     <= test_reg_w;
    status_reg   <= status_reg_w;
    command_reg  <= command_reg_w;
  end
end

assign mm_ack_o = (c_state == state_valid && valid_mm_rqst)? 1'b1 : 0;
assign mm_err_o = (c_state == state_error && valid_mm_rqst)? 1'b1 : 0; 
assign mm_dat_o =  valid_mm_rqst ? data_read : 0;
assign control_out = command_reg;

//assign addr_mm_rqst = mm_addr_i; //valid_mm_rqst ? mm_addr_i : 0;
//assign data_mm_rqst = mm_dat_i; //valid_mm_rqst ? mm_dat_i : 0;


always @(*) begin
     
     n_state = c_state;
    case(c_state)
        state_idle: begin
            n_state = valid_mm_rqst ? state_valid : state_idle;
           // addr_mm_rqst = valid_mm_rqst ? mm_addr_i : 0;
           // data_mm_rqst = valid_mm_rqst ? mm_dat_i : 0;
        end
        state_valid: begin
           // n_state = !valid_mm_rqst ? state_idle : state_valid;
            n_state = state_idle;
        end

        state_error: begin
            n_state = state_idle;
        end
        default: begin
            n_state = state_idle;
        end
    endcase
end

always @(*) begin
    
    data_read = 32'h0;
    command_reg_w = command_reg;
    test_reg_w = test_reg;
    status_reg_w = status_reg;
    addr_mm_rqst = mm_addr_i; //valid_mm_rqst ? mm_addr_i : 0;
    data_mm_rqst = mm_dat_i; //valid_mm_rqst ? mm_dat_i : 0;

    case(addr_mm_rqst)
        8'h0:
            data_read = mm_we_i ? 32'b0 : 32'hdeaddead;
        8'h4: begin
            data_read = mm_we_i ? 32'b0 : test_reg;  // for testing write and read.
            test_reg_w = (mm_we_i  && valid_mm_rqst) ? data_mm_rqst : test_reg;
        end
        8'h8: begin
            data_read = mm_we_i ? 32'b0 : status_reg;
            status_reg_w = (mm_we_i && valid_mm_rqst) ? data_mm_rqst : status_reg;
        end
        8'hc: begin
            data_read = mm_we_i ? 32'b0 : command_reg;
            command_reg_w = (mm_we_i && valid_mm_rqst) ? data_mm_rqst : command_reg;
        end
        default: begin
            
        end
    endcase
end

endmodule


