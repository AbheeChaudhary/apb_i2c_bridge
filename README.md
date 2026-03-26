# AMBA APB to I2C Protocol Bridge

## Overview
A synthesizable Register Transfer Level (RTL) implementation of a protocol bridge translating high-speed AMBA APB bus transactions to standard I2C serial communication. This IP block is designed to integrate low-speed peripherals into a high-performance System-on-Chip (SoC) environment, specifically capable of interfacing with a custom 32-bit RISC-V (RV32I) CPU core.

## Technical Specifications
* **Hardware Description Language:** Verilog (IEEE 1364-2005)
* **Simulation & Verification:** Icarus Verilog
* **Waveform Analysis:** GTKWave
* **Automation:** Bash Shell Scripting

## Directory Structure
```text
apb_i2c_bridge/
├── src/                 # Synthesizable RTL source files
│   └── apb_i2c_bridge.v
├── tb/                  # Verification environment and testbenches
│   └── tb_apb_i2c.v
├── runs/                # Simulation outputs and VCD waveform files
├── docs/                # Project documentation and diagrams
├── sim.sh               # Automated compilation and simulation script
└── README.md


## Verification Strategy and Simulation Results
A self-checking testbench was developed to verify dynamic wait-state insertion during the parallel-to-serial conversion of a simulated processor payload (0xA5).

Waveform Image : Waveform demonstrating successful wait-state insertion. The APB bus is stalled (pready = 0) while the I2C FSM accurately serializes the 10100101 payload, followed by a clean bus release.


## Quickstart : How to run

A bash script for running is included. It also works on latest mac version of GTKwave which must be built from source. 
The script compiles the RTL, runs the testbench and launches GTKWave natively on macOS.

```bash

chmod +x sim.sh
# this makes the script executable rather than plain text

./sim.sh


```


