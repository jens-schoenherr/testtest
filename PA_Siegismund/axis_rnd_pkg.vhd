----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

--library htwdd_ds;
use work.axis_data_gen_pkg.all;
use work.axis_data_cmp_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package axis_rnd_pkg is

  

  --constant data_arr_gen_c : data_arr_t := data_arr_c;--  & x"00";
  
 impure function generate_data_arr return data_arr_t;
  

  
end package axis_rnd_pkg;



package body axis_rnd_pkg is

 impure function generate_data_arr return data_arr_t is
    variable temp_arr : data_arr_t(0 to 14);
	variable rnd_val : std_logic_vector(7 downto 0);
  begin
    -- Perform any necessary initialization
    temp_arr := (others => (others => '0'));
    randomize(10, 15);
    -- Generate the data_arr_gen_c array using a loop
	for i in 0 to 14 loop
		temp_arr(i) := random(rnd_val'length);
		--rnd <= rnd_arr_s(i);
		--wait for 10 ns;
		
		end loop;
	
    --for i in data_arr_c'range loop
      -- Perform any necessary transformations on the data
      --temp_arr(i) := data_arr_c(i) & x"00";
    --end loop;

    return temp_arr;
  end generate_data_arr;
end package body axis_rnd_pkg;
