`include "defines.svh"

module top();
    
    import ram_package::*; // Importing the full compilation package framework
    
    // Global control signals
    logic clk;
    logic reset;
    
    // Generating 50MHz Clock Structure
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Period = 20ns -> Freq = 50MHz
    end

    // Asserting and de-asserting Reset active window
    initial begin
	@(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk); // Hold for 5 cycles to overlap driver delay
        reset = 1;
        @(posedge clk);
        reset = 1;
        repeat(5) @(posedge clk); // Hold for 5 cycles to overlap driver delay
        reset = 0;
        
        
    end

    // Hardware interface mapping instance
    ram_if intrf(clk, reset);

    // Design Under Verification (Unmodified RV-VLSI RTL)
    RAM DUV (
        .clk(clk),
        .reset(~reset),              
        .address(intrf.address),
        .data_in(intrf.data_in),
        .write_enb(intrf.write_enb),
        .read_enb(intrf.read_enb),
        .data_out(intrf.data_out)
    );

    // Declaring test bench variant handles at module level
    ram_test        t1;
    test_write      t2;
    test_read       t3;
    test_regression reg_tb;

    initial begin
        t1     = new(intrf, intrf, intrf);
        t2     = new(intrf, intrf, intrf);
        t3     = new(intrf, intrf, intrf);
        reg_tb = new(intrf, intrf, intrf); 

        t1.run();      
        #100;
        
        reg_tb.run();  // Phase 3: The 2000 random transactions
        #100;
        
        $finish(); 
    end
endmodule
