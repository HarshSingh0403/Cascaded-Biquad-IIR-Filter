`timescale 1ns / 1ps
// =====================================================
// CASCADED NON-PIPELINED BIQUAD FILTER (3 Stages)
//
// Signal flow: x_in -> Stage1 -> Stage2 -> Stage3 -> y_out
//
// Each stage is a 2nd-order biquad, so 3 stages
// together make a 6th-order low-pass filter.
//
// Total latency: 3 clock cycles (1 per stage)
// Throughput:    1 sample per clock cycle
// =====================================================

module cascaded_biquad (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,
    output wire signed [15:0] y_out,
    output wire        valid_out
);

    // Wires connecting Stage 1 -> Stage 2 -> Stage 3
    wire signed [15:0] y_stage1, y_stage2;
    wire               v_stage1, v_stage2;

   
    biquad_section #(
        .B0( 16'sd4096),   .B1( 16'sd8192),   .B2( 16'sd4096),
        .A1(-16'sd8192),   .A2( 16'sd4096)
    ) stage1 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(valid_in),    .x_in(x_in),
        .y_out(y_stage1),       .valid_out(v_stage1)
    );

    
    biquad_section #(
        .B0( 16'sd4096),   .B1( 16'sd8192),   .B2( 16'sd4096),
        .A1(-16'sd8192),   .A2( 16'sd4096)
    ) stage2 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(v_stage1),    .x_in(y_stage1),
        .y_out(y_stage2),       .valid_out(v_stage2)
    );

    
    biquad_section #(
        .B0( 16'sd4096),   .B1( 16'sd8192),   .B2( 16'sd4096),
        .A1(-16'sd8192),   .A2( 16'sd4096)
    ) stage3 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(v_stage2),    .x_in(y_stage2),
        .y_out(y_out),          .valid_out(valid_out)
    );

endmodule
