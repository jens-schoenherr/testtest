----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.env.all;

----------------------------------------------------------------------------------
package tb_utils_2008_pkg is

  type tb_status_t is (tb_success, tb_not_checked);

  -- This procedure must be called if the testbench should finisch with success.
  procedure end_sim(tb_name: string; status: tb_status_t := tb_success);

  -- calls "assert false" with the message and incremente err_cnt
  procedure assert_cnt(message: string; variable err_cnt: inout natural);
  
  -- Waits for n clk cycles (i.e. rising edges)
  procedure wait_clk(signal clk: std_logic; n: natural);
  -- Waits for n clk cycles (falling edges)
  procedure wait_clk_fe(signal clk: std_logic; n: natural);
  
  -- Generates an n clk cycle pulse of sig.
  -- a) sig is set to val and 
  -- b) after n rising edges of clk  (using wait_clk)
  -- c) sig is set back to "not val".
  procedure pulse(signal sig: out std_logic; val: std_logic; signal clk: std_logic; n: natural);
  -- same as pulse but with falling edge of clock (using wait_clk_fe)
  procedure pulse_cfe(signal sig: out std_logic; val: std_logic; signal clk: std_logic; n: natural);
  
  -- Returns the index in val which is set to '1'.
  -- If more than one bit of val is set to '1' the lowest index is returned.
  -- If no bit of val is '1' this function returns 0.
  function one_pos(val: std_logic_vector) return integer;
  
  -- return v as one-hot value (vth bit of return value is set)
  function to_onehot(v: natural; bit_width: natural) return std_logic_vector;

  -- returns true iff s contains a value /= '0' or /= '1' 
  function is_01(s: std_ulogic)        return boolean;
  function is_01(s: std_ulogic_vector) return boolean;
 -- function is_01(s: std_logic_vector)  return boolean;

  constant gsr_time_c : time := 100 ns; -- at lease valid for xilinx s3e

end package;


----------------------------------------------------------------------------------
package body tb_utils_2008_pkg is

  procedure end_sim(tb_name: string; status: tb_status_t := tb_success) is
  begin
    case status is
    when tb_success     => assert false report tb_name & " Simulation finished successfully."  severity note;
    when tb_not_checked => assert false report tb_name & " Simulation finished without check." severity note;
    end case;
    -- finish(0); -- VHDL'2008, forces a console message that function finish() has been called.
    stop(0); -- VHDL'2008
  end procedure;

  procedure assert_cnt(message: string; variable err_cnt: inout natural) is
  begin
    assert false report message severity error;
    err_cnt := err_cnt + 1;
  end procedure;
  
  procedure wait_clk(signal clk: std_logic; n: natural) is
  begin
    for i in 0 to n-1 loop
      wait until clk = '1';
    end loop;  
  end procedure;
  
  procedure wait_clk_fe(signal clk: std_logic; n: natural) is
  begin
    for i in 0 to n-1 loop
      wait until clk = '0';
    end loop;  
  end procedure;

  procedure pulse(signal sig: out std_logic; val: std_logic; signal clk: std_logic; n: natural) is
  begin
    sig <= val;
    wait_clk(clk, n);
    sig <= not val;
  end procedure;

  procedure pulse_cfe(signal sig: out std_logic; val: std_logic; signal clk: std_logic; n: natural) is
  begin
    sig <= val;
    wait_clk_fe(clk, n);
    sig <= not val;
  end procedure;

  function one_pos(val: std_logic_vector) return integer is
    variable ret : integer := 0;
  begin
    for i in val'high downto val'low loop
      if val(i) = '1' then
        ret := i;
      end if;
    end loop;
    return ret;
  end function;

  function to_onehot(v: natural; bit_width: natural) return std_logic_vector is
    variable res: std_logic_vector(bit_width-1 downto 0);
  begin
    res := (others => '0');
    res(v) := '1';
    return res;
  end function;  
  
  function is_01(s: std_ulogic) return  boolean is
  begin
    case s is
      when '0' | '1' => null;
      when others    => return false;
    end case;
    return true;
  end;
  function is_01(s: std_ulogic_vector) return  boolean is
  begin
    for i in s'range loop
      case s(i) is
        when '0' | '1' => null;
        when others    => return false;
      end case;
    end loop;
    return true;
  end;
  --function is_01(s: std_logic_vector) return  boolean is
  --begin
  --  for i in s'range loop
  --    case s(i) is
  --      when '0' | '1' => null;
  --      when others    => return false;
  --    end case;
  --  end loop;
  --  return true;
  --end;

end package body;
