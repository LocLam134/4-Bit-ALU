`timescale 1ns / 1ps
module adder_subtractor_4bit (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire sub,
    output wire [3:0] sum,
    output wire c3,
    output wire c4
);
    wire [3:0] b_inverted;
    wire [4:0] carry_chain;

    assign carry_chain[0] = sub;

    // Invert operand B and add 1 for two's complement subtraction
    xor xor_b0 (b_inverted[0], b[0], sub);
    xor xor_b1 (b_inverted[1], b[1], sub);
    xor xor_b2 (b_inverted[2], b[2], sub);
    xor xor_b3 (b_inverted[3], b[3], sub);

    // 4-bit Ripple Carry Adder instantiation
    full_adder fa0 (.a(a[0]), .b(b_inverted[0]), .cin(carry_chain[0]), .sum(sum[0]), .cout(carry_chain[1]));
    full_adder fa1 (.a(a[1]), .b(b_inverted[1]), .cin(carry_chain[1]), .sum(sum[1]), .cout(carry_chain[2]));
    full_adder fa2 (.a(a[2]), .b(b_inverted[2]), .cin(carry_chain[2]), .sum(sum[2]), .cout(carry_chain[3]));
    full_adder fa3 (.a(a[3]), .b(b_inverted[3]), .cin(carry_chain[3]), .sum(sum[3]), .cout(carry_chain[4]));

    assign c3 = carry_chain[3];
    assign c4 = carry_chain[4];
endmodule