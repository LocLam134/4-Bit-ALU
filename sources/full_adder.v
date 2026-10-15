`timescale 1ns / 1ps
module full_adder (
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);
    wire prop_sig;
    wire gen_sig;
    wire and_prop_cin;

    // 1-bit Full Adder logic: Compute sum and carry-out
    xor xor_prop (prop_sig, a, b);
    xor xor_sum  (sum, prop_sig, cin);
    and and_gen  (gen_sig, a, b);
    and and_pc   (and_prop_cin, prop_sig, cin);
    or  or_cout  (cout, gen_sig, and_prop_cin);
endmodule