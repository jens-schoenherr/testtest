----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library htwdd_ds;
use htwdd_ds.axis_data_gen_pkg.all;
use htwdd_ds.axis_data_cmp_pkg.all;

package axis_fifo_tb_pkg is

  constant axis_gen_params_c : axis_gen_param_arr_t := (
    (len =>  1, rate => 0, wait_clks =>   7, tlast => '1', test_id => 00),
    (len =>  2, rate => 0, wait_clks =>   2, tlast => '1', test_id => 01),
    (len => 14, rate => 0, wait_clks =>   1, tlast => '1', test_id => 02),
    (len =>  3, rate => 0, wait_clks =>   2, tlast => '1', test_id => 03),
    (len => 27, rate => 1, wait_clks =>   2, tlast => '1', test_id => 04),    
    (len => 16, rate => 0, wait_clks =>   2, tlast => '1', test_id => 05)
  );
  
  constant axis_cmp_params_c : axis_cmp_param_arr_t := (
    (len =>   1, rate => 0, wait_clks =>    8,  test_id => 00),
    (len =>   2, rate => 0, wait_clks =>    0,  test_id => 01),
    (len =>  14, rate => 0, wait_clks =>   18,  test_id => 02),
    (len =>   3, rate => 0, wait_clks =>    0,  test_id => 03),
    (len =>  27, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len =>  16, rate => 0, wait_clks =>    0,  test_id => 05)
  );

  constant data_arr_c : data_arr_t := (
           x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0a", x"0b", x"0c", x"0d", x"0e", x"0f",
    x"10", x"11", x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19", x"1a", x"1b", x"1c", x"1d", x"1e", x"1f",
    x"20", x"21", x"22", x"23", x"24", x"25", x"26", x"27", x"28", x"29", x"2a", x"2b", x"2c", x"2d", x"2e", x"2f",
    x"30", x"31", x"32", x"33", x"34", x"35", x"36", x"37", x"38", x"39", x"3a", x"3b", x"3c", x"3d", x"3e", x"3f"
  );

  --constant data_arr_gen_c : data_arr_t := data_arr_c;--  & x"00";
  
end package axis_fifo_tb_pkg;

package body axis_fifo_tb_pkg is
end package body axis_fifo_tb_pkg;
