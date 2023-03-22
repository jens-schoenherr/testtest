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

package axis_reg_tb_pkg is

  constant axis_gen_params_c : axis_gen_param_arr_t := (
    (len =>  1, rate => 5, wait_clks =>   10, tlast => '1', test_id => 00),
    (len =>  2, rate => 0, wait_clks =>    0, tlast => '1', test_id => 01),
    (len =>  4, rate => 0, wait_clks =>    0, tlast => '1', test_id => 02),
    (len =>  3, rate => 0, wait_clks =>    0, tlast => '1', test_id => 03),
    (len =>  6, rate => 0, wait_clks =>    0, tlast => '1', test_id => 04),    
    (len =>  1, rate => 6, wait_clks =>   50, tlast => '1', test_id => 05),
    (len =>  2, rate => 0, wait_clks =>    0, tlast => '1', test_id => 06),
    (len =>  4, rate => 2, wait_clks =>    0, tlast => '1', test_id => 07),
    (len =>  3, rate => 4, wait_clks =>   20, tlast => '1', test_id => 08),
    (len =>  3, rate => 1, wait_clks =>   10, tlast => '0', test_id => 09),    
    (len =>  3, rate => 2, wait_clks =>    1, tlast => '1', test_id => 10),
    (len =>  4, rate => 2, wait_clks =>   50, tlast => '1', test_id => 11),
    (len =>  4, rate => 3, wait_clks =>   12, tlast => '1', test_id => 12),
    (len =>  4, rate => 0, wait_clks =>    9, tlast => '1', test_id => 13),
    (len =>  4, rate => 2, wait_clks =>   10, tlast => '1', test_id => 14)
  );
  
  constant axis_cmp_params_c : axis_cmp_param_arr_t := (
    (len =>  1, rate => 4, wait_clks =>   10,  test_id => 00),
    (len =>  2, rate => 0, wait_clks =>   10,  test_id => 01),
    (len =>  4, rate => 1, wait_clks =>   10,  test_id => 02),
    (len =>  3, rate => 2, wait_clks =>    0,  test_id => 03),
    (len =>  6, rate => 3, wait_clks =>   20,  test_id => 04),    
    (len =>  1, rate => 3, wait_clks =>   50,  test_id => 05),
    (len =>  2, rate => 0, wait_clks =>    0,  test_id => 06),
    (len =>  4, rate => 0, wait_clks =>    0,  test_id => 07),
    (len =>  3, rate => 0, wait_clks =>    0,  test_id => 08),
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 09),    
    (len =>  4, rate => 3, wait_clks =>   50,  test_id => 10),
    (len =>  4, rate => 2, wait_clks =>   10,  test_id => 11),
    (len =>  4, rate => 2, wait_clks =>   10,  test_id => 12),
    (len =>  4, rate => 0, wait_clks =>   10,  test_id => 13)
  );

  constant data_arr_c : data_arr_t := (
  -- test cmp
    x"00",
    x"01", x"02",
    x"03", x"04", x"05", x"06",
    x"07", x"08", x"09",
    x"0a", x"0b", x"0c", x"0d", x"0e", x"0f",
  -- test gen
    x"01",
    x"11", x"12",
    x"13", x"14", x"15", x"16",
    x"17", x"18", x"19",
    x"1a", x"1b", x"1c", x"1d", x"1e", x"1f",
  -- test both
    x"20",
    x"21", x"22",
    x"23", x"24", x"25", x"26",
    x"27", x"28", x"29",
    x"2a", x"2b", x"2c", x"2d", x"2e", x"2f"
  );

  --constant data_arr_gen_c : data_arr_t := data_arr_c;--  & x"00";
  
end package axis_reg_tb_pkg;

package body axis_reg_tb_pkg is
end package body axis_reg_tb_pkg;
