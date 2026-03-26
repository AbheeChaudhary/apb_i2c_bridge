#!/bin/bash

echo "Starting Simulation Flow for APB-I2C Bridge..."

rm -f runs/bridge_sim.vvp runs/apb_i2c_waves.vcd

echo "Compiling RTL and Testbench..."
iverilog -o runs/bridge_sim.vvp src/apb_i2c_bridge.v tb/tb_apb_i2c.v


if [ $? -ne 0 ]; then
    echo "Compilation failed! Please check your Verilog syntax."
    exit 1
fi

echo "‍️Running Simulation..."
vvp runs/bridge_sim.vvp

if [ -f "runs/apb_i2c_waves.vcd" ]; then
    echo "Opening GTKWave..."
    GTKWave runs/apb_i2c_waves.vcd
    echo "Flow Complete!"
else
    echo "Simulation ran, but no VCD file was generated. Check your \$dumpvars."
fi
