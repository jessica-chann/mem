module testbench;

    logic clk, rst_n;
    logic start, done_gen_pattern, received_input, is_equal, play_again;

    logic in;
    logic clr;

    logic gen_pattern, incr_score;

    logic [15:0] count;
    logic [15:0] user_guess;
    logic [15:0] game_pattern;

    // Generate a clock
    always #5 clk = ~clk;

    // Init modules
    classicMode classic_fsm (.clk(clk), .rst_n(rst_n), .start(start), 
                             .done_gen_pattern(done_gen_pattern), 
                             .received_input(received_input), .is_equal(is_equal), 
                             .play_again(play_again),
                             .gen_pattern(gen_pattern), .incr_score(incr_score), .clr(clr)
    );

    counter     ctr         (.clk(clk), .rst_n(rst_n), .en(incr_score), .clr(clr),
                             .count(count)
    ); 

    comparator  cmp         (.received_input(recieved_input), 
                             .game_pattern(game_pattern), input_pattern(user_guess),
                             .is_equal(is_equal)
    );

    input_handler ih        (.clk(clk), .rst_n(rst_n), .in(in), .count(count), 
                             .received_input(received_input), .user_guess(user_guess)
    );

    // Testing input_handler
    initial begin
        // Initial state
        clk = 0;
        rst_n = 0;
        in = 0;
        count = 5;

        // Reset sequence
        #12 rst_n = 1;

        // Apply 5 input bits one at a time
        logic [4:0] input_bits = 5'b10110;
        for (int i = 0; i < 5; i++) begin
            in = input_bits[4 - i];  // shift in MSB first
            #10;  // one clock cycle
            $display("Cycle %0d: in = %b, user_guess = %b, received_input = %b", 
                     i+1, in, user_guess, received_input);
        end

        // Extra clock to confirm no more shifting
        #10;
        $display("Final: user_guess = %b, received_input = %b", user_guess, received_input);

        $finish;
    end
endmodule