`timescale 1ns / 1ps
// =====================================================
// PIPELINED BIQUAD FILTER (Direct Form I, 2-Stage)
//
// Same equation: y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2]
//                                - a1*y[n-1] - a2*y[n-2]
//
// Split into 2 pipeline stages:
//   Stage 1 (Cycle 1): Do all 5 multiplications
//   Stage 2 (Cycle 2): Add the products + output result
//
// Shorter critical path -> higher clock speed
// Takes 2 cycles per sample instead of 1.
// =====================================================

module biquad_section_pipelined #(
    
    parameter signed [15:0] B0 =  16'sd4096,   // b0 = 0.25
    parameter signed [15:0] B1 =  16'sd8192,   // b1 = 0.50
    parameter signed [15:0] B2 =  16'sd4096,   // b2 = 0.25
    parameter signed [15:0] A1 = -16'sd8192,   // a1 = -0.50
    parameter signed [15:0] A2 =  16'sd4096    // a2 = 0.25
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,
    output reg  signed [15:0] y_out,
    output reg         valid_out
);

    
    reg signed [15:0] x_d1, x_d2;   // x[n-1], x[n-2]
    reg signed [15:0] y_d1, y_d2;   // y[n-1], y[n-2]

    
    // PIPELINE STAGE 1: MULTIPLY
    
    reg signed [31:0] pr_b0, pr_b1, pr_b2;      
    reg signed [31:0] pr_a1, pr_a2;              
    reg               stage1_done;                

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pr_b0       <= 32'sd0;
            pr_b1       <= 32'sd0;
            pr_b2       <= 32'sd0;
            pr_a1       <= 32'sd0;
            pr_a2       <= 32'sd0;
            stage1_done <= 1'b0;
            x_d1        <= 16'sd0;
            x_d2        <= 16'sd0;
        end else begin
            stage1_done <= 1'b0;

            // Only accept input when Stage 2 is free
            if (valid_in && !stage1_done) begin
                pr_b0 <= x_in * B0;             // b0 * x[n]
                pr_b1 <= x_d1 * B1;             // b1 * x[n-1]
                pr_b2 <= x_d2 * B2;             // b2 * x[n-2]
                pr_a1 <= y_d1 * A1;             // a1 * y[n-1]
                pr_a2 <= y_d2 * A2;             // a2 * y[n-2]
                // Update input delay line
                x_d2 <= x_d1;
                x_d1 <= x_in;
                // Signal Stage 2
                stage1_done <= 1'b1;
            end
        end
    end


    // PIPELINE STAGE 2: ADD + OUTPUT

    wire signed [39:0] sum;
    assign sum = pr_b0 + pr_b1 + pr_b2 - pr_a1 - pr_a2;

    // Drop 14 fraction bits -> 16-bit result
    wire signed [15:0] y_new;
    assign y_new = sum[29:14];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y_out     <= 16'sd0;
            y_d1      <= 16'sd0;
            y_d2      <= 16'sd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;

            if (stage1_done) begin
                y_out <= y_new;                 
                y_d1  <= y_new;                 
                y_d2  <= y_d1;
                valid_out <= 1'b1;
            end
        end
    end

endmodule
