module classicMode (
    input  logic        clk, rst_n,
    input  logic        start, received_input, is_equal, play_again, 

    output logic        gen_pattern, incr_score, clr, input_handler_en
);

    enum logic [1:0] {INIT, PATTERN_GEN, WAIT, GAME_OVER} state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) state <= INIT;
        else state <= next_state;
    end

    // next state logic
    always_comb begin
        case (state)
            INIT: next_state = (start) ? PATTERN_GEN : INIT;
            PATTERN_GEN: next_state = WAIT;
            WAIT: begin
                if (received_input && is_equal) next_state = PATTERN_GEN;
                else if (received_input && !is_equal) next_state = GAME_OVER;
                else next_state = WAIT;
            end
            GAME_OVER: next_state = (play_again) ? INIT : GAME_OVER;
        endcase
    end

    // output logic
    // assign gen_pattern = (state == INIT && start) ? 1 : 0;
    assign gen_pattern = (next_state == PATTERN_GEN);
    assign incr_score = (state == WAIT && is_equal) ? 1 : 0;
  	// assign input_handler_en = (state == PATTERN_GEN ) || state == WAIT));
    assign input_handler_en = (state == WAIT && next_state == WAIT);
    assign clr = (state == INIT || play_again == 1) ? 1 : 0;

endmodule : classicMode


module random_bit_generator (
    input  logic clk, rst_n, en,     
    output logic random_bit 
);

    logic [31:0] lfsr_reg;
  
    // Generate a random seed
    function logic [31:0] get_random_seed();
        bit [31:0] seed;
        // Use SystemVerilog's random function to generate seed
        if (!$value$plusargs("seed=%d", seed))
            seed = $urandom; 
        return seed;
    endfunction
  
    // LFSR polynomial: x^32 + x^22 + x^2 + x^1 + 1 (maximal length)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) lfsr_reg <= get_random_seed();
        else if (en) lfsr_reg <= {lfsr_reg[30:0], lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0]};
    end
  
    // Output is the LSB of the LFSR
    assign random_bit = lfsr_reg[0];

endmodule : random_bit_generator


module shift_reg (
    input  logic        clk, rst_n, en, bit_in,
    output logic [31:0] data

);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) data <= 32'b0;
      else if (en) data <= {data[30:0], bit_in};
end
endmodule : shift_reg


module counter (
    input  logic        clk, rst_n, en, clr,
    output logic [15:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n || clr) count <= 1;
        else if (en) count <= count + 1;
    end
endmodule : counter


module comparator (
    input  logic        received_input,
    input  logic [31:0] game_pattern, input_pattern,
    output logic        is_equal   
);
    assign is_equal = (received_input && (game_pattern == input_pattern));

endmodule : comparator


module input_handler (
    input  logic        clk, rst_n, in, en, clr,
    input  logic [15:0] count,
    output logic        received_input,
    output logic [31:0] user_guess
);
    logic [15:0] bit_counter;

    always_ff @(posedge clk or negedge rst_n) begin
      if (~rst_n && clr) begin
            user_guess      <= 16'd0;
            bit_counter     <= 16'd0;
      end else if (en) begin
            if (bit_counter != count) begin
                user_guess  <= {user_guess[30:0], in};
                bit_counter <= bit_counter + 1;
            end
        end
    end

    assign received_input = (count != 0 && bit_counter == count);

endmodule : input_handler