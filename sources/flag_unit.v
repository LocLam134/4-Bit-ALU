`timescale 1ns / 1ps
// =====================================================================
// Module      : flag_unit
// Description : Generates ALU status flags (Carry, Zero, Overflow, 
//               Negative, and Div_by_zero exception) based on operations.
// =====================================================================
module flag_unit (
    input wire [7:0] result,
    input wire arith,
    input wire is_shl,
    input wire is_shr,
    input wire is_muldiv,
    input wire c3,
    input wire c4,
    input wire shl_out_bit,
    input wire shr_out_bit,
    output wire carry,
    output wire zero,
    output wire overflow,
    output wire negative
);
    // Update status flags (Carry, Zero, Overflow, Negative) based on the active operation
    assign carry    = (arith & c4) | (is_shl & shl_out_bit) | (is_shr & shr_out_bit);
    assign overflow = arith & (c3 ^ c4);
    assign zero     = ~|result;
    assign negative = ~is_muldiv & result[3];
endmodule