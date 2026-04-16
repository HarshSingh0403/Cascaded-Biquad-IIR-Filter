`timescale 1ns / 1ps
// =====================================================
// NON-PIPELINED BIQUAD FILTER (Direct Form I)
//
// Computes:  y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2]
//                            - a1*y[n-1] - a2*y[n-2]
//
// All 5 multiplications + addition happen in ONE cycle.
// Coefficients are in Q2.14 fixed-point format.
// =====================================================

module biquad_section #(
    // ---- Filter coefficients (Q2.14 format) ----
    // To convert: multiply real value by 16384
    //   0.25 x 16384 = 4096,  0.50 x 16384 = 8192
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

   
    reg signed [15:0] x_d1, x_d2;   // x[n-1] and x[n-2]
    reg signed [15:0] y_d1, y_d2;   // y[n-1] and y[n-2]

   
    
    wire signed [31:0] prod_b0 = x_in * B0;    // b0 * x[n]
    wire signed [31:0] prod_b1 = x_d1 * B1;    // b1 * x[n-1]
    wire signed [31:0] prod_b2 = x_d2 * B2;    // b2 * x[n-2]

    
    wire signed [31:0] prod_a1 = y_d1 * A1;    // a1 * y[n-1]
    wire signed [31:0] prod_a2 = y_d2 * A2;    // a2 * y[n-2]

    
    wire signed [39:0] sum;
    assign sum = prod_b0 + prod_b1 + prod_b2 - prod_a1 - prod_a2;

    
    wire signed [15:0] y_new;
    assign y_new = sum[29:14];

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset everything to zero
            x_d1      <= 16'sd0;
            x_d2      <= 16'sd0;
            y_d1      <= 16'sd0;
            y_d2      <= 16'sd0;
            y_out     <= 16'sd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0;              // Default: no output
            if (valid_in) begin
                // Shift delay lines
                x_d2 <= x_d1;              // x[n-2] = old x[n-1]
                x_d1 <= x_in;              // x[n-1] = current input
                y_d2 <= y_d1;              // y[n-2] = old y[n-1]
                y_d1 <= y_new;             // y[n-1] = current output
                // Output the result
                y_out     <= y_new;
                valid_out <= 1'b1;
            end
        end
    end

endmodule
