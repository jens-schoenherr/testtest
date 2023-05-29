#!/bin/bash
echo Analyse Packages
ghdl -a --std=08 -frelaxed axis_pkg.vhd
ghdl -a --std=08 -frelaxed axis_reg_pkg.vhd
ghdl -a --std=08 -frelaxed axis_data_gen_pkg.vhd
ghdl -a --std=08 -frelaxed axis_data_cmp_pkg.vhd
ghdl -a --std=08 -frelaxed axis_rnd_pkg.vhd
ghdl -a --std=08 -frelaxed axis_reg_tb_pkg.vhd
ghdl -a --std=08 -frelaxed integer_fcn_pkg.vhd
ghdl -a --std=08 -frelaxed tb_utils_2008_pkg.vhd
ghdl -a --std=08 -frelaxed txt_util.vhd
ghdl -a --std=08 -frelaxed axis_data_gen.vhd
ghdl -a --std=08 -frelaxed axis_data_cmp.vhd
echo Analyse File
ghdl -a --std=08 -frelaxed axis_reg.vhd
echo Analyse Testbench
ghdl -a --std=08 -frelaxed axis_reg_tb.vhd
echo Elaborate Testbench
ghdl -e --std=08 -frelaxed axis_reg_tb
echo Run Simulation
ghdl -r --std=08 -frelaxed axis_reg_tb --vcd=axis_reg_tb_wave.vcd
echo Display generated Waveforms
gtkwave axis_reg_tb_wave.vcd