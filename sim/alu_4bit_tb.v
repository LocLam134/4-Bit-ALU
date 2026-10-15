`timescale 1ns / 1ps

// =====================================================================
// Student Name : Lam Duy Loc
// Student ID   : SE190907
// Project      : 4-bit ALU Design & Verification (Self-Checking Testbench)
// =====================================================================

module alu_4bit_tb;

    // Internal signal declarations for driving the DUT (Device Under Test)
    reg sim_clk = 0;
    reg sim_rst = 1;
    reg sim_start = 0;
    reg [3:0] operand_a = 0;
    reg [3:0] operand_b = 0;
    reg [3:0] operation_code = 0;

    // Wires for capturing DUT outputs and status flags
    wire [7:0] alu_result;
    wire flg_carry, flg_zero, flg_overflow, flg_negative, flg_dbz, alu_busy, alu_done;

    // DUT Instantiation: Mapping testbench signals to ALU ports
    alu_4bit dut (
        .clk(sim_clk), 
        .rst(sim_rst), 
        .start(sim_start),
        .a(operand_a), 
        .b(operand_b), 
        .opcode(operation_code),
        .result(alu_result),
        .carry(flg_carry), 
        .zero(flg_zero),
        .overflow(flg_overflow), 
        .negative(flg_negative),
        .div_by_zero(flg_dbz), 
        .busy(alu_busy), 
        .done(alu_done)
    );

    // Clock generator: 100 MHz frequency (10 ns period)
    always #5 sim_clk = ~sim_clk;

    // Variables for the Golden Reference Model
    reg [3:0] ref_result;
    reg ref_carry, ref_overflow;
    reg [4:0] adder_temp;

    // Golden Reference Model: Computes expected results for single-cycle operations
    task model;
    begin
        ref_carry = 0; 
        ref_overflow = 0; 
        ref_result = 0;
        case (operation_code)
            // ADD operation: A + B
            4'b0000: begin 
                adder_temp = {1'b0, operand_a} + {1'b0, operand_b}; 
                ref_result = adder_temp[3:0]; 
                ref_carry = adder_temp[4]; 
                ref_overflow = (operand_a[3] == operand_b[3]) && (ref_result[3] != operand_a[3]); 
            end
            // SUB operation: A - B (using two's complement)
            4'b0001: begin 
                adder_temp = {1'b0, operand_a} + {1'b0, ~operand_b} + 5'd1; 
                ref_result = adder_temp[3:0]; 
                ref_carry = adder_temp[4]; 
                ref_overflow = (operand_a[3] != operand_b[3]) && (ref_result[3] != operand_a[3]); 
            end
            // Logical AND
            4'b0010: ref_result = operand_a & operand_b;
            // Logical OR
            4'b0011: ref_result = operand_a | operand_b;
            // Logical XOR
            4'b0100: ref_result = operand_a ^ operand_b;
            // Logical NOT (Invert A)
            4'b0101: ref_result = ~operand_a;
            // Shift Left (SHL)
            4'b0110: begin 
                ref_result = {operand_a[2:0], 1'b0}; 
                ref_carry = operand_a[3]; 
            end
            // Shift Right (SHR)
            4'b0111: begin 
                ref_result = {1'b0, operand_a[3:1]}; 
                ref_carry = operand_a[0]; 
            end
            default: ref_result = 0;
        endcase
    end
    endtask

    integer cycle_count;
    
    // Task to execute and monitor multi-cycle operations (MUL / DIV)
    task run_md(input [3:0] op, input [3:0] x, input [3:0] y);
    begin
        @(negedge sim_clk);
        operation_code = op; 
        operand_a = x; 
        operand_b = y; 
        sim_start = 1; // Assert start signal
        @(negedge sim_clk);
        sim_start = 0; // De-assert start signal
        cycle_count = 0;
        // Wait until computation is done, counting clock cycles for latency check
        while (!alu_done) begin 
            @(negedge sim_clk); 
            cycle_count = cycle_count + 1; 
        end
    end
    endtask

    integer idx, err_count, op_idx;
    reg [7:0] combined_inputs;

    initial begin
        // Print student information to Tcl Console
        $display("====================================");
        $display("STUDENT NAME : Lam Duy Loc");
        $display("STUDENT ID   : SE190907");
        $display("====================================");

       
        $display("------------------------------------------------------------");
        $display("  Op   code |  A   B | result      | flags / notes");
        $display("------------------------------------------------------------");

        begin : PRINT_TABLE
            reg [23:0] op_str;
            integer i;
            reg [11:0] test_cases [0:9];

            
            test_cases[0] = {4'b0000, 4'd3,  4'd4};   // ADD 3 4
            test_cases[1] = {4'b0000, 4'd15, 4'd1};   // ADD 15 1
            test_cases[2] = {4'b0001, 4'd5,  4'd3};   // SUB 5 3
            test_cases[3] = {4'b0001, 4'd3,  4'd5};   // SUB 3 5
            test_cases[4] = {4'b0010, 4'd12, 4'd10};  // AND 12 10
            test_cases[5] = {4'b0011, 4'd12, 4'd10};  // OR 12 10
            test_cases[6] = {4'b0100, 4'd12, 4'd10};  // XOR 12 10
            test_cases[7] = {4'b0101, 4'd12, 4'd0};   // NOT 12
            test_cases[8] = {4'b0110, 4'd11, 4'd0};   // SHL 11
            test_cases[9] = {4'b0111, 4'd11, 4'd0};   // SHR 11

            for (i = 0; i < 10; i = i + 1) begin
                operation_code = test_cases[i][11:8];
                operand_a      = test_cases[i][7:4];
                operand_b      = test_cases[i][3:0];
                #10; 

                
                case(operation_code)
                    4'b0000: op_str = "ADD";
                    4'b0001: op_str = "SUB";
                    4'b0010: op_str = "AND";
                    4'b0011: op_str = " OR";
                    4'b0100: op_str = "XOR";
                    4'b0101: op_str = "NOT";
                    4'b0110: op_str = "SHL";
                    4'b0111: op_str = "SHR";
                    default: op_str = "UNK";
                endcase

                
                $display(" %3s   %4b | %2d  %2d | %8b ( %2d) | C=%b Z=%b V=%b N=%b",
                    op_str, operation_code, operand_a, operand_b,
                    alu_result, alu_result,
                    flg_carry, flg_zero, flg_overflow, flg_negative);
            end
        end
        $display("------------------------------------------------------------\n");
        
        // Reset sequence
        #12 sim_rst = 0;
        err_count = 0;

        // Part 1: Exhaustive check for all single-cycle combinational operations (3,584 test cases)
        for (op_idx = 0; op_idx < 16; op_idx = op_idx + 1) begin
            if (op_idx != 8 && op_idx != 9) begin
                for (idx = 0; idx < 256; idx = idx + 1) begin
                    operation_code = op_idx; 
                    {operand_a, operand_b} = idx; 
                    #1;
                    model; // Calculate reference values
                    
                    // Compare DUT outputs against Golden Model expected values
                    if (alu_result !== {4'b0, ref_result} || flg_carry !== ref_carry || flg_overflow !== ref_overflow || flg_zero !== (ref_result == 0) || flg_negative !== ref_result[3]) begin
                        err_count = err_count + 1;
                        if (err_count <= 10) 
                            $display("FAIL op=%b a=%0d b=%0d got %b expected %b", operation_code, operand_a, operand_b, alu_result, ref_result);
                    end
                end
            end
        end

        // Part 2: Exhaustive check for multi-cycle Sequential MUL and DIV operations (512 test cases)
        for (idx = 0; idx < 256; idx = idx + 1) begin
            combined_inputs = idx;
            
            // Multiplier verification: A * B
            run_md(4'b1000, combined_inputs[7:4], combined_inputs[3:0]);
            if (alu_result !== combined_inputs[7:4] * combined_inputs[3:0] || cycle_count + 1 != 5 || flg_zero !== (alu_result == 0)) begin
                err_count = err_count + 1;
                if (err_count <= 10) 
                    $display("FAIL MUL %0d * %0d got %0d", combined_inputs[7:4], combined_inputs[3:0], alu_result);
            end

            // Divider verification: A / B and Division-by-Zero exception check
            run_md(4'b1001, combined_inputs[7:4], combined_inputs[3:0]);
            if (combined_inputs[3:0] == 0) begin
                // Check if division by zero exception is handled correctly
                if (flg_dbz != 1 || alu_result[3:0] !== 4'b1111 || alu_result[7:4] !== combined_inputs[7:4]) begin
                    err_count = err_count + 1;
                    if (err_count <= 10) 
                        $display("FAIL DIV %0d / 0", combined_inputs[7:4]);
                end
            end else if (alu_result[3:0] !== combined_inputs[7:4] / combined_inputs[3:0] || alu_result[7:4] !== combined_inputs[7:4] % combined_inputs[3:0] || flg_dbz !== 0) begin
                // Check valid division quotient and remainder
                err_count = err_count + 1;
                if (err_count <= 10) 
                    $display("FAIL DIV %0d / %0d got q=%0d r=%0d", combined_inputs[7:4], combined_inputs[3:0], alu_result[3:0], alu_result[7:4]);
            end
        end

        // Final Verification Summary
        if (err_count == 0)
            $display("\nPASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors\n");
        else
            $display("\nFAILED: %0d errors\n", err_count);
            
        $finish;
    end

endmodule