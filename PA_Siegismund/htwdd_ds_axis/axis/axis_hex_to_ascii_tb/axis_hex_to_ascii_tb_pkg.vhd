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

package axis_hex_to_ascii_tb_pkg is

  constant axis_gen_params_c : axis_gen_param_arr_t := (
    (len =>  1, rate => 0, wait_clks =>   10, tlast => '1', test_id => 00),
    (len =>  2, rate => 0, wait_clks =>    5, tlast => '1', test_id => 01),
    (len =>  4, rate => 0, wait_clks =>    5, tlast => '1', test_id => 02),
    (len =>  2, rate => 0, wait_clks =>    0, tlast => '1', test_id => 03),
    (len =>  2, rate => 0, wait_clks =>    3, tlast => '1', test_id => 04),    
    (len =>  2, rate => 1, wait_clks =>    3, tlast => '1', test_id => 05),
    (len =>  2, rate => 0, wait_clks =>    3, tlast => '1', test_id => 06),
    (len =>  2, rate => 1, wait_clks =>    3, tlast => '1', test_id => 07),
    (len =>  2, rate => 2, wait_clks =>    3, tlast => '1', test_id => 08)
  );
  
  constant axis_hex_none_cmp_params_c : axis_cmp_param_arr_t := (
    (len => 2, rate => 0, wait_clks =>   10,  test_id => 00),
    (len => 4, rate => 0, wait_clks =>    5,  test_id => 01),
    (len => 8, rate => 0, wait_clks =>    4,  test_id => 02),
    (len => 4, rate => 0, wait_clks =>    0,  test_id => 03),
    (len => 4, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len => 4, rate => 0, wait_clks =>    0,  test_id => 05),
    (len => 4, rate => 1, wait_clks =>    0,  test_id => 06),
    (len => 4, rate => 2, wait_clks =>    0,  test_id => 07),
    (len => 4, rate => 1, wait_clks =>    0,  test_id => 08)
  );

  constant axis_hex_cr_cmp_params_c : axis_cmp_param_arr_t := (
    (len => 3, rate => 0, wait_clks =>   10,  test_id => 00),
    (len => 5, rate => 0, wait_clks =>    5,  test_id => 01),
    (len => 9, rate => 0, wait_clks =>    4,  test_id => 02),
    (len => 5, rate => 0, wait_clks =>    0,  test_id => 03),
    (len => 5, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len => 5, rate => 0, wait_clks =>    0,  test_id => 05),
    (len => 5, rate => 1, wait_clks =>    0,  test_id => 06),
    (len => 5, rate => 2, wait_clks =>    0,  test_id => 07),
    (len => 5, rate => 1, wait_clks =>    0,  test_id => 08)
  );

  constant axis_hex_crlf_cmp_params_c : axis_cmp_param_arr_t := (
    (len =>  4, rate => 0, wait_clks =>   10,  test_id => 00),
    (len =>  6, rate => 0, wait_clks =>    5,  test_id => 01),
    (len => 10, rate => 0, wait_clks =>    4,  test_id => 02),
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 03),
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 05),
    (len =>  6, rate => 1, wait_clks =>    0,  test_id => 06),
    (len =>  6, rate => 2, wait_clks =>    0,  test_id => 07),
    (len =>  6, rate => 1, wait_clks =>    0,  test_id => 08)
  );

  constant axis_dec_none_cmp_params_c : axis_cmp_param_arr_t := (
    (len =>  3, rate => 0, wait_clks =>   10,  test_id => 00),
    (len =>  6, rate => 0, wait_clks =>    5,  test_id => 01),
    (len => 12, rate => 0, wait_clks =>    4,  test_id => 02),
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 03),
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len =>  6, rate => 0, wait_clks =>    0,  test_id => 05),
    (len =>  6, rate => 1, wait_clks =>    0,  test_id => 06),
    (len =>  6, rate => 2, wait_clks =>    0,  test_id => 07),
    (len =>  6, rate => 1, wait_clks =>    0,  test_id => 08)
  );

  constant axis_dec_cr_cmp_params_c : axis_cmp_param_arr_t := (
    (len =>  4, rate => 0, wait_clks =>   10,  test_id => 00),
    (len =>  7, rate => 0, wait_clks =>    5,  test_id => 01),
    (len => 13, rate => 0, wait_clks =>    4,  test_id => 02),
    (len =>  7, rate => 0, wait_clks =>    0,  test_id => 03),
    (len =>  7, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len =>  7, rate => 0, wait_clks =>    0,  test_id => 05),
    (len =>  7, rate => 1, wait_clks =>    0,  test_id => 06),
    (len =>  7, rate => 2, wait_clks =>    0,  test_id => 07),
    (len =>  7, rate => 1, wait_clks =>    0,  test_id => 08)
  );

  constant axis_dec_crlf_cmp_params_c : axis_cmp_param_arr_t := (
    (len =>  5, rate => 0, wait_clks =>   10,  test_id => 00),
    (len =>  8, rate => 0, wait_clks =>    5,  test_id => 01),
    (len => 14, rate => 0, wait_clks =>    4,  test_id => 02),
    (len =>  8, rate => 0, wait_clks =>    0,  test_id => 03),
    (len =>  8, rate => 0, wait_clks =>    0,  test_id => 04),    
    (len =>  8, rate => 0, wait_clks =>    0,  test_id => 05),
    (len =>  8, rate => 1, wait_clks =>    0,  test_id => 06),
    (len =>  8, rate => 2, wait_clks =>    0,  test_id => 07),
    (len =>  8, rate => 1, wait_clks =>    0,  test_id => 08)
  );

  constant data_arr_gen_c : data_arr_t := (
    x"00",
    x"12", x"34",
    x"56", x"78", x"9a", x"bc",
    x"de", x"ff",
    x"f0", x"e1",
    x"d2", x"c3",
    x"b4", x"a5",
    x"96", x"87",
    x"78", x"69"
  );

  constant data_arr_hex_none_cmp_c : data_arr_t := (
    x"30", x"30",
    x"31", x"32", x"33", x"34",
    x"35", x"36", x"37", x"38", x"39", x"41", x"42", x"43",
    x"44", x"45", x"46", x"46",
    x"46", x"30", x"45", x"31",
    x"44", x"32", x"43", x"33",
    x"42", x"34", x"41", x"35",
    x"39", x"36", x"38", x"37",
    x"37", x"38", x"36", x"39"
  );
  
  constant data_arr_hex_cr_cmp_c : data_arr_t := (
    x"30", x"30", x"0d",
    x"31", x"32", x"33", x"34", x"0d",
    x"35", x"36", x"37", x"38", x"39", x"41", x"42", x"43", x"0d",
    x"44", x"45", x"46", x"46", x"0d",
    x"46", x"30", x"45", x"31", x"0d",
    x"44", x"32", x"43", x"33", x"0d",
    x"42", x"34", x"41", x"35", x"0d",
    x"39", x"36", x"38", x"37", x"0d",
    x"37", x"38", x"36", x"39", x"0d"
  );
  
  constant data_arr_hex_crlf_cmp_c : data_arr_t := (
    x"30", x"30", x"0d", x"0a",
    x"31", x"32", x"33", x"34", x"0d", x"0a",
    x"35", x"36", x"37", x"38", x"39", x"41", x"42", x"43", x"0d", x"0a",
    x"44", x"45", x"46", x"46", x"0d", x"0a",
    x"46", x"30", x"45", x"31", x"0d", x"0a",
    x"44", x"32", x"43", x"33", x"0d", x"0a",
    x"42", x"34", x"41", x"35", x"0d", x"0a",
    x"39", x"36", x"38", x"37", x"0d", x"0a",
    x"37", x"38", x"36", x"39", x"0d", x"0a"
  );
  
  constant data_arr_dec_none_cmp_c : data_arr_t := (
    x"30", x"30", x"30",
    x"30", x"31", x"38", x"30", x"35", x"32",
    x"30", x"38", x"36", x"31", x"32", x"30", x"31", x"35", x"34", x"31", x"38", x"38",
    x"32", x"32", x"32", x"32", x"35", x"35",
    x"32", x"34", x"30", x"32", x"32", x"35",
    x"32", x"31", x"30", x"31", x"39", x"35",
    x"31", x"38", x"30", x"31", x"36", x"35",
    x"31", x"35", x"30", x"31", x"33", x"35",
    x"31", x"32", x"30", x"31", x"30", x"35"
  );
  
  constant data_arr_dec_cr_cmp_c : data_arr_t := (
    x"30", x"30", x"30", x"0d",
    x"30", x"31", x"38", x"30", x"35", x"32", x"0d",
    x"30", x"38", x"36", x"31", x"32", x"30", x"31", x"35", x"34", x"31", x"38", x"38", x"0d",
    x"32", x"32", x"32", x"32", x"35", x"35", x"0d",
    x"32", x"34", x"30", x"32", x"32", x"35", x"0d",
    x"32", x"31", x"30", x"31", x"39", x"35", x"0d",
    x"31", x"38", x"30", x"31", x"36", x"35", x"0d",
    x"31", x"35", x"30", x"31", x"33", x"35", x"0d",
    x"31", x"32", x"30", x"31", x"30", x"35", x"0d"
  );
  
  constant data_arr_dec_crlf_cmp_c : data_arr_t := (
    x"30", x"30", x"30", x"0d", x"0a",
    x"30", x"31", x"38", x"30", x"35", x"32", x"0d", x"0a",
    x"30", x"38", x"36", x"31", x"32", x"30", x"31", x"35", x"34", x"31", x"38", x"38", x"0d", x"0a",
    x"32", x"32", x"32", x"32", x"35", x"35", x"0d", x"0a",
    x"32", x"34", x"30", x"32", x"32", x"35", x"0d", x"0a",
    x"32", x"31", x"30", x"31", x"39", x"35", x"0d", x"0a",
    x"31", x"38", x"30", x"31", x"36", x"35", x"0d", x"0a",
    x"31", x"35", x"30", x"31", x"33", x"35", x"0d", x"0a",
    x"31", x"32", x"30", x"31", x"30", x"35", x"0d", x"0a"
  );
  
end package axis_hex_to_ascii_tb_pkg;

package body axis_hex_to_ascii_tb_pkg is
end package body axis_hex_to_ascii_tb_pkg;
