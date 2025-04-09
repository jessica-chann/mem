// Code your testbench here
// or browse Examples
module testbench();

    // Declare signals
    logic clk, rst_n;
    logic start, done_gen_pattern, received_input, is_equal, play_again;
    logic in;
    logic clr;
    logic gen_pattern, incr_score;
  
  	logic input_handler_en;
    logic [15:0] count;
    logic [15:0] user_guess;
    logic [4:0] input_bits;

    // Instantiate modules
    classicMode classic_fsm (
        .clk(clk), 
        .rst_n(rst_n),
        .start(start),
        .done_gen_pattern(done_gen_pattern),
        .received_input(received_input),
        .is_equal(is_equal),
        .play_again(play_again),
        .gen_pattern(gen_pattern),
        .incr_score(incr_score),
        .clr(clr),
        .input_handler_en(input_handler_en)
    );

    input_handler ih (
        .clk(clk), 
        .rst_n(rst_n), 
        .in(in),
      	.en(input_handler_en),
      	.clr(clr),
        .count(count), 
        .received_input(received_input), 
        .user_guess(user_guess)
    );
  	
  	initial begin
    	rst_n = 1'b0;
    	rst_n <= 1'b1;
    	clk = 1'b0;
    	forever #5 clk = ~clk;

        start <= 0;
        done_gen_pattern <= 0;
        is_equal <= 0;
        play_again <= 0;
      	@(posedge clk);
  	end

    initial begin
        // Initialize values
        start <= 1;
        @(posedge clk);

        start <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        done_gen_pattern <= 1;
        count <= 'd5;
      	input_bits <= 5'b10110;
      	@(posedge clk);
      	
        $display("input_handler_en = %b", input_handler_en);
      	for (int i = 0; i < 5; i++) begin
            in <= input_bits[4 - i];  // Shift in MSB first
            @(posedge clk);  // Synchronize to the rising edge of clk
            $display("Cycle %0d: in = %b, user_guess = %b, received_input = %b", 
                     i+1, in, user_guess, received_input);
        end

        // Extra clock cycle to confirm no more shifting
        @(posedge clk);
        $display("Final: user_guess = %b, received_input = %b", user_guess, received_input);

        $finish();
    end

endmodule : testbench
