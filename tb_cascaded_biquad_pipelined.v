`timescale 1ns / 1ps
// =====================================================
// TESTBENCH - Pipelined Cascaded Biquad Filter
//
// Two tests:
//   Test 1: Impulse response - one spike then zeros
//   Test 2: Step response   - constant input value
//
// Pipelined has 8-cycle latency so runs longer.
// Waveform shows ONLY: clk, rst_n, x_in, y_out, valid_out
// =====================================================

module tb_cascaded_biquad_pipelined;


    parameter CLK_PERIOD = 10;


    reg         clk;
    reg         rst_n;
    reg         valid_in;
    reg  signed [15:0] x_in;
    wire signed [15:0] y_out;
    wire        valid_out;

 
    cascaded_biquad_pipelined uut (
        .clk(clk), .rst_n(rst_n),
        .valid_in(valid_in), .x_in(x_in),
        .y_out(y_out), .valid_out(valid_out)
    );

   
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    
    integer i;

    initial begin
        // Waveform: only dump the 5 essential signals
        $dumpfile("pl_waveform.vcd");
        $dumpvars(0, tb_cascaded_biquad_pipelined.clk);
        $dumpvars(0, tb_cascaded_biquad_pipelined.rst_n);
        $dumpvars(0, tb_cascaded_biquad_pipelined.x_in);
        $dumpvars(0, tb_cascaded_biquad_pipelined.y_out);
        $dumpvars(0, tb_cascaded_biquad_pipelined.valid_out);

    
        rst_n    = 0;
        valid_in = 0;
        x_in     = 16'sd0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        
        // x[0]=1000, then all zeros
        $display("");
        $display("==== TEST 1: IMPULSE RESPONSE (Pipelined) ====");
        $display(" Cycle |  Input |  Output | Valid");
        $display("-------|--------|---------|------");

        valid_in = 1;
        x_in     = 16'sd1000;
        @(posedge clk);

        x_in = 16'sd0;
        for (i = 0; i < 60; i = i + 1) begin
            @(posedge clk);
            $display(" %4d  | %6d | %7d |   %b", i, x_in, y_out, valid_out);
        end

        valid_in = 0;
        repeat (10) @(posedge clk);

        
        // x[n]=500 for all n
        $display("");
        $display("==== TEST 2: STEP RESPONSE (Pipelined) ====");
        $display(" Cycle |  Input |  Output | Valid");
        $display("-------|--------|---------|------");

        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        valid_in = 1;
        x_in     = 16'sd500;
        for (i = 0; i < 80; i = i + 1) begin
            @(posedge clk);
            $display(" %4d  | %6d | %7d |   %b", i, x_in, y_out, valid_out);
        end

        valid_in = 0;
        repeat (5) @(posedge clk);

        $display("");
        $display("==== SIMULATION COMPLETE ====");
        $finish;
    end

endmodule
