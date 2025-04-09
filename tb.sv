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

    // Instantiate the input_handler module
    input_handler ih (
        .clk(clk), 
        .rst_n(rst_n), 
        .in(in),
      	.en(input_handler_en),
        .count(count), 
        .received_input(received_input), 
        .user_guess(user_guess)
    );
  	
  	initial begin
    	rst_n = 1'b0;
    	rst_n <= 1'b1;
    	clk = 1'b0;
    	forever #5 clk = ~clk;
      	@(posedge clk);
  	end

    // Testbench initial block
    initial begin
        // Initialize values
        count <= 'd5;
      	input_bits <= 5'b10110;
      	@(posedge clk);
      	
      	input_handler_en <= 1;
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
