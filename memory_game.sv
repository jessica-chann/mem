module classicMode (
    input  logic        clk, rst_n,
    input  logic        start, done_gen_pattern, received_input, is_equal, play_again, 

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
            PATTERN_GEN: next_state = (done_gen_pattern) ? WAIT : PATTERN_GEN;
            WAIT: begin
                if (received_input && is_equal) next_state = PATTERN_GEN;
                else if (received_input && !is_equal) next_state = GAME_OVER;
                else next_state = WAIT;
            end
            GAME_OVER: next_state = (play_again) ? INIT : GAME_OVER;
        endcase
    end

    // output logic
    assign gen_pattern = (state == PATTERN_GEN) ? 1 : 0;
    assign incr_score = (state == WAIT && is_equal) ? 1 : 0;
    // assign input_handler_en = (state == PATTERN_GEN && done_gen_pattern) || state == WAIT));
  	assign input_handler_en = (state == WAIT);
    assign clr = (state == INIT) ? 1 : 0;

endmodule : classicMode


module counter (
    input  logic        clk, rst_n, en, clr,
    output logic [15:0] count
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n || clr) count <= 0;
        else count <= count + 1;
    end
endmodule : counter


module comparator (
    input  logic        received_input,
    input  logic [15:0] game_pattern, input_pattern,
    output logic        is_equal   
);
    assign is_equal = (received_input && (game_pattern == input_pattern));

endmodule : comparator


module input_handler (
    input  logic        clk, rst_n, in, en, clr,
    input  logic [15:0] count,
    output logic        received_input,
    output logic [15:0] user_guess
);
    logic [15:0] bit_counter;

    always_ff @(posedge clk or negedge rst_n) begin
      if (~rst_n && clr) begin
            user_guess      <= 16'd0;
            bit_counter     <= 16'd0;
      end else if (en) begin
            if (bit_counter != count) begin
                user_guess <= {user_guess[14:0], in};
                bit_counter <= bit_counter + 1;
            end
        end
    end

    assign received_input = (bit_counter == count);

endmodule : input_handler