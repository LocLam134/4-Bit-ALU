// =====================================================================
// Module      : muldiv_unit
// Description : Sequential 4-bit unsigned multiplier (shift-and-add) 
//               and restoring divider. Executes in 5 clock cycles.
// =====================================================================


`timescale 1ns / 1ps
module muldiv_unit (
    input wire clk,
    input wire rst,
    input wire start,
    input wire is_div,
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [3:0] add_a,
    output wire [3:0] add_b,
    output wire add_sub,
    input wire [3:0] add_sum,
    input wire add_c4,
    output wire [3:0] hi,
    output wire [3:0] lo,
    output wire busy,
    output reg done,
    output reg div_by_zero
);
    reg [3:0] acc, q, m;
    reg [1:0] count;
    reg running;
    reg mode_div;

    wire [3:0] r_shift = {acc[2:0], q[3]};
    wire r_top = acc[3];
    wire fits = r_top | add_c4;

    assign add_a   = mode_div ? r_shift : acc;
    assign add_b   = m;
    assign add_sub = mode_div;
    assign busy    = running;
    assign hi      = acc;
    assign lo      = q;

    // FSM (Finite State Machine) logic for sequential operations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc         <= 4'd0;
            q           <= 4'd0;
            m           <= 4'd0;
            count       <= 2'd0;
            running     <= 1'b0;
            mode_div    <= 1'b0;
            done        <= 1'b0;
            div_by_zero <= 1'b0;
        end else if (start && !running) begin
            running     <= 1'b1;
            done        <= 1'b0;
            mode_div    <= is_div;
            count       <= 2'd0;
            acc         <= 4'd0;
            q           <= is_div ? a : b;
            m           <= is_div ? b : a;
            
            // Exception handling: Detect and set flag for division by zero
            div_by_zero <= is_div && (b == 4'd0);
        end else if (running) begin
            if (!mode_div) begin
                // Datapath for shift-and-add multiplier algorithm
                if (q[0])
                    {acc, q} <= {add_c4, add_sum, q[3:1]};
                else
                    {acc, q} <= {1'b0, acc, q[3:1]};
            end else begin
                // Datapath for restoring division algorithm
                if (fits) begin
                    acc <= add_sum;
                    q   <= {q[2:0], 1'b1};
                end else begin
                    acc <= r_shift;
                    q   <= {q[2:0], 1'b0};
                end
            end
            count <= count + 2'd1;
            if (count == 2'd3) begin
                running <= 1'b0;
                done    <= 1'b1;
            end
        end
    end
endmodule