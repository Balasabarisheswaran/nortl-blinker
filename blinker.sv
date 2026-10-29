module nortl_sync #(
    parameter DATA_WIDTH = 1
) (
    input  logic CLK_I,
    input  logic RST_ASYNC_I,

    input  logic [DATA_WIDTH-1:0] IN,
    output logic [DATA_WIDTH-1:0] OUT,

    output logic CLK_REQ
);

always @(posedge CLK_I or posedge RST_ASYNC_I)
begin
    if (RST_ASYNC_I)
    begin
        OUT <= {DATA_WIDTH{1'b0}};
    end
    else begin
        OUT <= IN;
    end
end

always_comb begin
    CLK_REQ = OUT != IN;
end

endmodule

module nortl_edge_detector(
    input  logic CLK_I,
    input  logic RST_ASYNC_I,

    input  logic SIGNAL,
    output logic RISING,
    output logic FALLING,

    output logic CLK_REQ
);

logic [1:0] sr;

always_ff @(posedge CLK_I or posedge RST_ASYNC_I)
begin
    if (RST_ASYNC_I)
    begin
        sr <= 2'b00;
    end
    else begin
        sr <= {sr[0], SIGNAL};
    end
end

always_comb begin
    RISING = (sr == 2'b01);
    FALLING = (sr == 2'b10);
end

always_comb begin
    CLK_REQ = sr != {sr[0], SIGNAL};
end

endmodule

module nortl_delay #(
    parameter DATA_WIDTH = 1,
    parameter DELAY_STEPS = 2
) (
    input logic CLK_I,
    input logic RST_ASYNC_I,

    input  logic [DATA_WIDTH-1:0] IN,
    output logic [DATA_WIDTH-1:0] OUT,

    output logic CLK_REQ
);

logic [DATA_WIDTH-1:0] shiftreg [DELAY_STEPS-1:0];

always_ff @(posedge CLK_I or posedge RST_ASYNC_I) begin
    if (RST_ASYNC_I)
    begin
        for (int i=DELAY_STEPS-1; i>=0; i=i-1)
        begin
            shiftreg[i] <= {DATA_WIDTH{1'b0}};
        end
    end
    else begin
        if (DELAY_STEPS == 1)
        begin
            shiftreg[0] <= IN;
        end
        else begin
            for (int i=DELAY_STEPS-2; i>=0; i=i-1)
            begin
                shiftreg[i+1] <= shiftreg[i];
            end
            shiftreg[0] <= IN;
        end
    end
end

always_comb begin
    if (DELAY_STEPS == 1)
    begin
        OUT = shiftreg[0];
    end
    else begin
        OUT = shiftreg[DELAY_STEPS-1];
    end
end

always_comb begin
    CLK_REQ = 0;

    if (DELAY_STEPS == 1)
    begin
        CLK_REQ = CLK_REQ | (shiftreg[0] != IN);
    end
    else begin
        for (int i=DELAY_STEPS-2; i>=0; i=i-1)
        begin
            CLK_REQ = CLK_REQ | (shiftreg[i+1] != shiftreg[i]);
        end
        CLK_REQ = CLK_REQ | (shiftreg[0] != IN);
    end
end


endmodule

module nortl_count_down_timer #(
    parameter DATA_WIDTH = 16
) (
    input  logic CLK_I,
    input  logic RST_ASYNC_I,

    input  logic RELOAD,
    input  logic [DATA_WIDTH-1:0] DELAY,
    output logic ZERO,

    output logic CLK_REQ
);

logic [DATA_WIDTH-1:0] counter;

always_ff @(posedge CLK_I or posedge RST_ASYNC_I)
begin
    if (RST_ASYNC_I)
    begin
        counter <= 0;
    end
    else begin
        if (RELOAD)
        begin
            if (DELAY > 2)
            begin
                counter <= DELAY - 2;
            end
        end
        else if (counter != 0) begin
            counter <= counter - 1;
        end
    end
end

always_comb begin
    ZERO = (counter == 0) & ~RELOAD;

    if (DELAY == 1)
    begin
        ZERO = ~RELOAD;
    end
    if (DELAY == 0)
    begin
        ZERO = ~RELOAD;
    end
end

always_comb begin
    CLK_REQ = RELOAD | (counter > 0);
end

endmodule

module nortl_clock_gate (
    input logic CLK_I,
    input logic EN,
    output logic GCLK_O
);

logic enable_latch;

always_latch begin
    if (~CLK_I)
    begin
        enable_latch = EN;
    end
end

always_comb begin
    GCLK_O = enable_latch & CLK_I;
end

endmodule


module blinker  (input logic CLK_I,
input logic RST_ASYNC_I,
input logic start,
output logic led,
output logic busy);
logic [32-1:0] SCRATCH_SIGNAL;
enum {IDLE, STATE_1, STATE_2, STATE_3, STATE_4, STATE_5, STATE_6, STATE_7, STATE_8, STATE_9, STATE_10, STATE_11, STATE_12, STATE_13, STATE_14, STATE_15, STATE_16, STATE_17, STATE_18, STATE_19, STATE_20} state, state_nxt;

always_comb
begin
   begin
      state_nxt = state;
   end
     case (state)
      IDLE: begin
         state_nxt = STATE_1;
      end
      STATE_1: begin
         if ((start == 1))
         begin
            state_nxt = STATE_2;
         end
      end
      STATE_3: begin
         state_nxt = STATE_19;
      end
      STATE_4: begin
         if ((SCRATCH_SIGNAL[15:0] == 4))
         begin
            state_nxt = STATE_3;
         end
         if (~((SCRATCH_SIGNAL[15:0] == 4)))
         begin
            state_nxt = STATE_5;
         end
      end
      STATE_6: begin
         state_nxt = STATE_11;
      end
      STATE_7: begin
         if ((SCRATCH_SIGNAL[31:16] == 3))
         begin
            state_nxt = STATE_6;
         end
         if (~((SCRATCH_SIGNAL[31:16] == 3)))
         begin
            state_nxt = STATE_8;
         end
      end
      STATE_8: begin
         state_nxt = STATE_9;
      end
      STATE_9: begin
         state_nxt = STATE_10;
      end
      STATE_10, STATE_5: begin
         state_nxt = STATE_7;
      end
      STATE_12: begin
         state_nxt = STATE_17;
      end
      STATE_13: begin
         if ((SCRATCH_SIGNAL[31:16] == 3))
         begin
            state_nxt = STATE_12;
         end
         if (~((SCRATCH_SIGNAL[31:16] == 3)))
         begin
            state_nxt = STATE_14;
         end
      end
      STATE_14: begin
         state_nxt = STATE_15;
      end
      STATE_15: begin
         state_nxt = STATE_16;
      end
      STATE_16, STATE_11: begin
         state_nxt = STATE_13;
      end
      STATE_17: begin
         state_nxt = STATE_18;
      end
      STATE_18, STATE_2: begin
         state_nxt = STATE_4;
      end
      STATE_19: begin
         if ((start == 0))
         begin
            state_nxt = STATE_20;
         end
      end
      STATE_20: begin
         state_nxt = IDLE;
      end
   endcase
end

always_ff @(posedge CLK_I or posedge RST_ASYNC_I)
begin
   if (RST_ASYNC_I)
   begin
      led <= 0;
      busy <= 0;
      SCRATCH_SIGNAL <= 0;
   end
   else 
   begin
        case (state_nxt)
         IDLE: begin
            led <= 0;
            busy <= 0;
            SCRATCH_SIGNAL <= 0;
         end
         STATE_2: begin
            busy <= 1;
            SCRATCH_SIGNAL[15:0] <= 0;
         end
         STATE_5: begin
            led <= 1;
            SCRATCH_SIGNAL[31:16] <= 0;
         end
         STATE_11: begin
            led <= 0;
            SCRATCH_SIGNAL[31:16] <= 0;
         end
         STATE_16, STATE_10: begin
            SCRATCH_SIGNAL[31:16] <= (SCRATCH_SIGNAL[31:16] + 1);
         end
         STATE_18: begin
            SCRATCH_SIGNAL[15:0] <= (SCRATCH_SIGNAL[15:0] + 1);
         end
         STATE_19: begin
            busy <= 0;
         end
      endcase
   end
end
// synthesis translate_off

always_ff @(posedge CLK_I or posedge RST_ASYNC_I)
begin
   if (RST_ASYNC_I)
   begin
      
   end
   else 
   begin
      
   end
end
// synthesis translate_on

always_comb
begin
   
end

always_ff @(posedge CLK_I or posedge RST_ASYNC_I)
begin
   if (RST_ASYNC_I)
   begin
      state <= IDLE;
   end
   else 
   begin
      if (0)
      begin
         state <= IDLE;
      end
      else 
      begin
         state <= state_nxt;
      end
   end
end
endmodule