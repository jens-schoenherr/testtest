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

package axis_fifo_b2_tb_pkg is

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

  constant data_arr_c : data2_arr_t := (
             x"0101", x"2002", x"0303", x"4004", x"0505", x"6006", x"0707", x"8008", x"0909", x"a00a", x"0b0b", x"c00c", x"0d0d", x"e00e", x"0f0f",
    x"0010", x"0111", x"2012", x"0313", x"4014", x"0515", x"6016", x"0717", x"8018", x"0919", x"a01a", x"0b1b", x"c01c", x"0d1d", x"e01e", x"0f1f",
    x"0020", x"0121", x"2022", x"0323", x"4024", x"0525", x"6026", x"0727", x"8028", x"0929", x"a02a", x"0b2b", x"c02c", x"0d2d", x"e02e", x"0f2f",
    x"0030", x"0131", x"2032", x"0333", x"4034", x"0535", x"6036", x"0737", x"8038", x"0939", x"a03a", x"0b3b", x"c03c", x"0d3d", x"e03e", x"0f3f"
  );

  --constant data_arr_gen_c : data_arr_t := data_arr_c;--  & x"00";

end package axis_fifo_b2_tb_pkg;

package body axis_fifo_b2_tb_pkg is
end package body axis_fifo_b2_tb_pkg;
