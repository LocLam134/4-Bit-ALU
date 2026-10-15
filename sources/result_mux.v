`timescale 1ns / 1ps
module result_mux (
    input wire [3:0] opcode,
    input wire [3:0] sum,
    input wire [3:0] and_out,
    input wire [3:0] or_out,
    input wire [3:0] xor_out,
    input wire [3:0] not_out,
    input wire [3:0] shl,
    input wire [3:0] shr,
    input wire [3:0] md_hi,
    input wire [3:0] md_lo,
    output reg [7:0] result
);
    // Route the correct computed result to the final 8-bit output bus based on opcode
    always @(*) begin
        case (opcode)
            4'b0000, 4'b0001: result = {4'b0000, sum};
            4'b0010:          result = {4'b0000, and_out};
            4'b0011:          result = {4'b0000, or_out};
            4'b0100:          result = {4'b0000, xor_out};
            4'b0101:          result = {4'b0000, not_out};
            4'b0110:          result = {4'b0000, shl};
            4'b0111:          result = {4'b0000, shr};
            4'b1000, 4'b1001: result = {md_hi, md_lo};
            default:          result = 8'b0000_0000;
        endcase
    end
endmodule