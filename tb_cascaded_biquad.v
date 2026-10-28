`timescale 1ns / 1ps
// =====================================================
// TESTBENCH - Non-Pipelined Cascaded Biquad Filter
//
// Two tests:
//   Test 1: Impulse response - one spike then zeros
//   Test 2: Step response   - constant input value
//
// Waveform shows ONLY: clk, rst_n, x_in, y_out, valid_out
// =====================================================

module tb_cascaded_biquad;

    // Clock period: 10 ns = 100 MHz
    parameter CLK_PERIOD = 10;

    // ---- DUT signals ----
    reg         clk;
    reg         rst_n;
    reg         valid_in;
    reg  signed [15:0] x_in;
    wire signed [15:0] y_out;
    wire        valid_out;

    // ---- Connect the filter ----
    cascaded_biquad uut (
        .clk(clk), .rst_n(rst_n),
        .valid_in(valid_in), .x_in(x_in),
        .y_out(y_out), .valid_out(valid_out)
    );

    // ---- Clock generator ----
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ---- Test sequence ----
    integer i;

    initial begin
        // Waveform: only dump the 5 essential signals
        $dumpfile("np_waveform.vcd");
        $dumpvars(0, tb_cascaded_biquad.clk);
        $dumpvars(0, tb_cascaded_biquad.rst_n);
        $dumpvars(0, tb_cascaded_biquad.x_in);
        $dumpvars(0, tb_cascaded_biquad.y_out);
        $dumpvars(0, tb_cascaded_biquad.valid_out);

        // ---- RESET ----
        rst_n    = 0;
        valid_in = 0;
        x_in     = 16'sd0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // ---- TEST 1: IMPULSE ----
        // x[0]=1000, then all zeros
        $display("");
        $display("==== TEST 1: IMPULSE RESPONSE ====");
        $display(" Cycle |  Input |  Output | Valid");
        $display("-------|--------|---------|------");

        valid_in = 1;
        x_in     = 16'sd1000;
        @(posedge clk);

        x_in = 16'sd0;
        for (i = 0; i < 40; i = i + 1) begin
            @(posedge clk);
            $display(" %4d  | %6d | %7d |   %b", i, x_in, y_out, valid_out);
        end

        valid_in = 0;
        repeat (10) @(posedge clk);

        // ---- TEST 2: STEP ----
        // x[n]=500 for all n
        $display("");
        $display("==== TEST 2: STEP RESPONSE ====");
        $display(" Cycle |  Input |  Output | Valid");
        $display("-------|--------|---------|------");

        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        valid_in = 1;
        x_in     = 16'sd500;
        for (i = 0; i < 50; i = i + 1) begin
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
