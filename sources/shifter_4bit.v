`timescale 1ns / 1ps
module shifter_4bit (
    input wire [3:0] a,
    output wire [3:0] shl,
    output wire [3:0] shr,
    output wire shl_out_bit,
    output wire shr_out_bit
);
    // Perform Logical Shift Left (SHL) and Logical Shift Right (SHR)
    assign shl         = {a[2:0], 1'b0};
    assign shr         = {1'b0, a[3:1]};
    
    // Capture the shifted-out bit (MSB or LSB) for the carry flag
    assign shl_out_bit = a[3];
    assign shr_out_bit = a[0];
endmodule