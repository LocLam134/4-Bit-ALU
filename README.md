# 🚀 4-Bit Arithmetic Logic Unit (ALU) with Self-Checking Verification

## 📌 Project Overview

This repository contains the RTL design and comprehensive verification of a robust **4-bit signed Arithmetic Logic Unit (ALU)** written in Verilog HDL.

Unlike standard introductory ALUs, this project implements a hybrid architecture capable of handling instantaneous **single-cycle combinational operations** (Addition, Subtraction, Logic) alongside complex **multi-cycle sequential operations** (Multiplication, Division) using a Finite State Machine (FSM). The system processes data using the Two's Complement format (range: -8 to +7).


## ✨ Key Features

* **Hybrid Datapath:** Integrates both 1-cycle combinational circuits and 5-cycle sequential hardware blocks within a unified top-level architecture.
* **Sequential Multiplier & Divider:** Employs the Shift-and-Add algorithm for multiplication and Restoring Division algorithm for division, heavily optimizing hardware resources.
* **Comprehensive Flag Detection:** Precisely calculates `Carry`, `Zero`, `Overflow`, `Negative`, and a dedicated `Divide-by-Zero` (DBZ) hardware exception.
* **Hardware-Accurate Limits:** Correctly processes binary constraints (e.g., `-8 + (-8) = 0` with `Overflow = 1` and `Carry = 1`).
* **Exhaustive Self-Checking Verification:** The testbench implements a Golden Reference Model that automatically iterates through **4,096 possible input combinations**, asserting outputs with 100% accuracy (0 errors).

## 🧮 Supported Instructions (Truth Table)

| Opcode (Hex) | Operation | Type / Latency | Description / Hardware Rule | 
| :---: | :---: | :--- | :--- | 
| `0000` | **ADD** | Combinational (1 cycle) | Arithmetic Addition `A + B` | 
| `0001` | **SUB** | Combinational (1 cycle) | Arithmetic Subtraction `A - B` (2's complement) | 
| `0010` | **AND** | Combinational (1 cycle) | Bitwise Logical AND | 
| `0011` | **OR** | Combinational (1 cycle) | Bitwise Logical OR | 
| `0100` | **XOR** | Combinational (1 cycle) | Bitwise Logical XOR | 
| `0101` | **NOT** | Combinational (1 cycle) | Bitwise Inversion `~A` | 
| `0110` | **SHL** | Combinational (1 cycle) | Logical Shift Left (Carry catches shifted MSB) | 
| `0111` | **SHR** | Combinational (1 cycle) | Logical Shift Right (Carry catches shifted LSB) | 
| `1000` | **MUL** | Sequential (5 cycles) | 8-bit output product `A * B` via FSM | 
| `1001` | **DIV** | Sequential (5 cycles) | `A / B`. Output: Upper 4-bits = Remainder, Lower 4-bits = Quotient | 

## 🏗️ Hardware Architecture

The RTL is highly modularized, translating directly into clean elaborated logic gates:

1. **`adder_subtractor_4bit.v`:** Computes basic arithmetic.
2. **`logic_unit_4bit.v`:** Handles AND, OR, XOR, NOT operations.
3. **`shifter_4bit.v`:** Manages SHL and SHR.
4. **`muldiv_unit.v`:** Contains the core FSM computing Multi-cycle MUL and DIV operations while managing `busy` and `done` handshaking signals.
5. **`flag_unit.v`:** Aggregates and asserts status flags.
6. **`mux.v`:** Hardware multiplexer routing the correct datapath to the output based on the opcode and `done` signals.

## 🔬 Verification & Testbench

The core highlight of this project is the `alu_4bit_tb.v`. Instead of manually verifying waveforms, the testbench acts as an automated checking system:

* **Golden Model Generation:** For every input, Verilog behavioral tasks calculate the absolute correct mathematical answer.
* **Exhaustive Scanning:** The testbench leverages nested loops to simulate all parameters.
  * `3,584` checks for single-cycle operations.
  * `512` checks for sequential operations.
* **Tcl Console Logging:** It intelligently outputs formatted edge-case logs (e.g., specific `ADD 8 8` testing boundaries, division by zero) directly to the Vivado terminal.

### 📜 Simulation Result

```text
====================================
STUDENT NAME : Lam Duy Loc
STUDENT ID   : SE190907
====================================
... [15 specific edge-cases successfully logged] ...

PASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors
```

## 🚀 How to Run in Vivado

1. Clone the repository to your local machine.
2. Open **Xilinx Vivado** and create a new RTL project.
3. Add all `.v` files from the `src/` directory as Design Sources.
4. Add `alu_4bit_tb.v` as the Simulation Source.
5. Run **RTL Analysis** to view the Elaborated Schematic.
6. Click **Run Simulation -> Run Behavioral Simulation**.
7. **Important:** By default, Vivado stops at `1000ns`. To execute the full 4096 test cases, click the **`Run All`** button (F3) on the top toolbar or type `run all` in the Tcl Console. Observe the final `PASS` log in the console.


## 👨‍💻 Author
- **Name:** Lam Duy Loc
- **Student ID:** SE190907
- **Specialization:** Semiconductor & Integrated Circuit Design — FPT University
- GitHub: https://github.com/LocLam134
- Email: loc.slh11357@gmail.com
