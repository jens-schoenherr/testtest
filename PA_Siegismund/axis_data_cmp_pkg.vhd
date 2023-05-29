----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

--library htwdd_ds;
use work.axis_pkg.all;
use work.axis_data_gen_pkg.all;

package axis_data_cmp_pkg is

  -- already declared in axis_data_gen_pkg
  -- type data_arr_t is array (natural range <>) of std_logic_vector(7 downto 0);

  type axis_cmp_param_t is record
    len       : natural; -- len of packet in bytes
    rate      : natural; -- number of clocks between two data bytes
    wait_clks : natural; -- number of clocks between last byte of the previous packet and the 1st on of the current packet
    test_id   : natural;
  end record;
  constant dflt_axis_cmp_param_c : axis_cmp_param_t := (
    len       => 0,
    rate      => 0,
    wait_clks => 0,
    test_id   => 0
  );
  type axis_cmp_param_arr_t is array (natural range <>) of axis_cmp_param_t;
  constant empty_axis_cmp_param_c : axis_cmp_param_arr_t(0 to -1) := (others => dflt_axis_cmp_param_c);

  component axis_data_cmp is
    generic (
      auto_repeat_g         : boolean := true;
      ready_at_end_g        : integer := -1;  -- negative numbers: no ready at end, positive numbers: number of wait cycles until the trailing ready
                                              -- The 1st successfull transfer after the end (last data from data_arr_g compared) lead to a deviation.
      axis_cmp_params_g : axis_cmp_param_arr_t := empty_axis_cmp_param_c;
      data_arr_g            : data_arr_t;
      kind_g                : string := "";
      async_rst_g           : boolean := false;
      active_rst_g          : std_logic := '0'
    );
    port (
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;

      -- axis slave i/f
      data_i       : in  axis_m2s_b1i0d0u0_t;
      data_o       : out axis_s2m_t;

      deviation_o  : out std_logic;   -- 1 if a deviation data_i vs. data_arr_g is detected
      data_over_o  : out std_logic    -- 1 if auto_repeat_g = false and all data have been compared
    );
  end component;

  component axis_data_cmp_b2 is
    generic (
      auto_repeat_g         : boolean := true;
      ready_at_end_g        : integer := -1;  -- negative numbers: no ready at end, positive numbers: number of wait cycles until the trailing ready
                                              -- The 1st successfull transfer after the end (last data from data_arr_g compared) lead to a deviation.
      axis_cmp_params_g : axis_cmp_param_arr_t := empty_axis_cmp_param_c;
      data_arr_g            : data2_arr_t;
      kind_g                : string := "";
      async_rst_g           : boolean := false;
      active_rst_g          : std_logic := '0'
    );
    port (
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;

      -- axis slave i/f
      data_i       : in  axis_m2s_b2i0d0u0_t;
      data_o       : out axis_s2m_t;

      deviation_o  : out std_logic;   -- 1 if a deviation data_i vs. data_arr_g is detected
      data_over_o  : out std_logic    -- 1 if auto_repeat_g = false and all data have been compared
    );
  end component;

  function max_cmp_len      (a: axis_cmp_param_arr_t) return natural;
  function max_cmp_rate     (a: axis_cmp_param_arr_t) return natural;
  function max_cmp_wait_clks(a: axis_cmp_param_arr_t) return natural;
  function max_cmp_test_id  (a: axis_cmp_param_arr_t) return natural;

end package axis_data_cmp_pkg;

package body axis_data_cmp_pkg is

  function max_cmp_len(a: axis_cmp_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).len > max then
        max := a(i).len;
      end if;
    end loop;
    return max;
  end;

  function max_cmp_rate(a: axis_cmp_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).rate > max then
        max := a(i).rate;
      end if;
    end loop;
    return max;
  end;

  function max_cmp_wait_clks(a: axis_cmp_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).wait_clks > max then
        max := a(i).wait_clks;
      end if;
    end loop;
    return max;
  end;

  function max_cmp_test_id(a: axis_cmp_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).test_id > max then
        max := a(i).test_id;
      end if;
    end loop;
    return max;
  end;

end package body;
