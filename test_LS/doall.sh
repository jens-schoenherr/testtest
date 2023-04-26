#!/bin/bash
echo Analyse File
ghdl -a --std=08 -frelaxed ha.vhdl
echo Analyse Testbench
ghdl -a --std=08 -frelaxed ha_tb.vhdl
echo Elaborate Testbench
ghdl -e --std=08 -frelaxed ha_tb
echo Run Simulation
ghdl -r --std=08 -frelaxed ha_tb --vcd=ha_tb_wave.vcd
echo Display generated Waveforms
gtkwave ha_tb_wave.vcd