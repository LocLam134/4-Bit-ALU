`timescale 1ns / 1ps
module control_unit (
    input wire [3:0] opcode,
    output wire sub,
    output wire arith,
    output wire is_shl,
    output wire is_shr,
    output wire is_div,
    output wire is_muldiv
);
    // Decode 4-bit opcode into internal control signals for active modules
    assign sub      = (opcode == 4'b0001);
    assign arith    = (opcode[3:1] == 3'b000);
    assign is_shl   = (opcode == 4'b0110);
    assign is_shr   = (opcode == 4'b0111);
    assign is_div   = (opcode == 4'b1001);
    assign is_muldiv= (opcode[3:1] == 3'b100);
endmodule