`timescale 1ns / 1ps
// =====================================================
// CASCADED PIPELINED BIQUAD FILTER (3 Stages)
//
// Signal flow:
//   x_in -> Biquad1 -> PR1 -> Biquad2 -> PR2 -> Biquad3 -> y_out
//
// PR = Pipeline Register (extra flip-flop between stages)
//
// Latency: Biquad1(2) + PR1(1) + Biquad2(2) + PR2(1) + Biquad3(2) = 8 cycles
// Throughput: 1 sample every 2 clock cycles
// =====================================================

module cascaded_biquad_pipelined (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,
    output wire signed [15:0] y_out,
    output wire        valid_out
);

    // ============ BIQUAD STAGE 1 ============
    wire signed [15:0] y_stage1;
    wire               v_stage1;

    biquad_section_pipelined #(
        .B0( 16'sd4096),   .B1( 16'sd8192),   .B2( 16'sd4096),
        .A1(-16'sd8192),   .A2( 16'sd4096)
    ) stage1 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(valid_in),    .x_in(x_in),
        .y_out(y_stage1),       .valid_out(v_stage1)
    );

    // ============ PIPELINE REGISTER 1 ============
    // Extra register between Stage 1 and Stage 2
    reg signed [15:0] pr1_data;
    reg               pr1_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pr1_data  <= 16'sd0;
            pr1_valid <= 1'b0;
        end else begin
            pr1_data  <= y_stage1;
            pr1_valid <= v_stage1;
        end
    end

    // ============ BIQUAD STAGE 2 ============
    wire signed [15:0] y_stage2;
    wire               v_stage2;

    biquad_section_pipelined #(
        .B0( 16'sd4096),   .B1( 16'sd8192),   .B2( 16'sd4096),
        .A1(-16'sd8192),   .A2( 16'sd4096)
    ) stage2 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(pr1_valid),   .x_in(pr1_data),
        .y_out(y_stage2),       .valid_out(v_stage2)
    );

    // ============ PIPELINE REGISTER 2 ============
    // Extra register between Stage 2 and Stage 3
    reg signed [15:0] pr2_data;
    reg               pr2_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pr2_data  <= 16'sd0;
            pr2_valid <= 1'b0;
        end else begin
            pr2_data  <= y_stage2;
            pr2_valid <= v_stage2;
        end
    end

    // ============ BIQUAD STAGE 3 ============
    biquad_section_pipelined #(
        .B0( 16'sd4096),   .B1( 16'sd8192),   .B2( 16'sd4096),
        .A1(-16'sd8192),   .A2( 16'sd4096)
    ) stage3 (
        .clk(clk), .rst_n(rst_n),
        .valid_in(pr2_valid),   .x_in(pr2_data),
        .y_out(y_out),          .valid_out(valid_out)
    );

endmodule
