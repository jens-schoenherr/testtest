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

package axis_data_gen_pkg is

  type data_arr_t is array (natural range <>) of std_logic_vector(7 downto 0);
  type data2_arr_t is array (natural range <>) of std_logic_vector(15 downto 0);
  function stdvec_to_arr(word: std_logic_vector) return data_arr_t;
  function stdvec_to_arr2(word: std_logic_vector) return data2_arr_t;
  function string_to_data_arr(s: string) return data_arr_t;

  type axis_gen_param_t is record
    len       : natural;   -- len of packet in bytes
    rate      : natural;   -- number of clocks between two data bytes
    wait_clks : natural;   -- number of clocks between last byte of the previous packet and the 1st on of the current packet
    tlast     : std_logic; -- if '0' then tlast is not signalized (used to model packet parts with different rates)
    test_id   : natural;   -- id of the test, just for information (print out in simulation)
  end record;
  constant dflt_axis_gen_param_c : axis_gen_param_t := (
    len       => 0,
    rate      => 0,
    wait_clks => 0,
    tlast     => 'U',
    test_id   => 0
  );
  type axis_gen_param_arr_t is array (natural range <>) of axis_gen_param_t;
  constant empty_axis_gen_param_c : axis_gen_param_arr_t(0 to -1) := (others => dflt_axis_gen_param_c);

  component axis_data_gen is
    generic (
      auto_repeat_g         : boolean := true;
      axis_gen_params_g : axis_gen_param_arr_t := empty_axis_gen_param_c;
      data_arr_g            : data_arr_t;
      kind_g                : string := "";
      async_rst_g           : boolean := false;
      active_rst_g          : std_logic := '0'
    );
    port (
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;

      -- axis master i/f
      data_i       : in  axis_s2m_t;
      data_o       : out axis_m2s_b1i0d0u0_t;

      done_o       : out std_logic;
      test_id_o    : out natural
    );
  end component;

  component axis_data_gen_b2 is
    generic (
      auto_repeat_g         : boolean := true;
      axis_gen_params_g : axis_gen_param_arr_t := empty_axis_gen_param_c;
      data_arr_g            : data2_arr_t;
      kind_g                : string := "";
      async_rst_g           : boolean := false;
      active_rst_g          : std_logic := '0'
    );
    port (
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;

      -- axis master i/f
      data_i       : in  axis_s2m_t;
      data_o       : out axis_m2s_b2i0d0u0_t;

      done_o       : out std_logic;
      test_id_o    : out natural
    );
  end component;

  function max_gen_len      (a: axis_gen_param_arr_t) return natural;
  function max_gen_rate     (a: axis_gen_param_arr_t) return natural;
  function max_gen_wait_clks(a: axis_gen_param_arr_t) return natural;
  function max_gen_test_id  (a: axis_gen_param_arr_t) return natural;

end package axis_data_gen_pkg;

package body axis_data_gen_pkg is

  function stdvec_to_arr(word: std_logic_vector) return data_arr_t is
    variable res0 : data_arr_t(0 to -1);
    variable res1 : data_arr_t(0 to 0);
    variable res2 : data_arr_t(0 to 1);
    variable res3 : data_arr_t(0 to 2);
    variable res4 : data_arr_t(0 to 3);
    variable res5 : data_arr_t(0 to 4);
    variable res6 : data_arr_t(0 to 5);
  begin
    if (word'length = 8) then
      res1 := (0 => word( 7 downto  0));
      return res1;
    elsif (word'length = 16) then
      res2 := (0 => word(15 downto  8),
               1 => word( 7 downto  0));
      return res2;
    elsif (word'length = 24) then
      res3 := (0 => word(23 downto 16),
               1 => word(15 downto  8),
               2 => word( 7 downto  0));
      return res3;
    elsif (word'length = 32) then
      res4 := (0 => word(31 downto 24),
               1 => word(23 downto 16),
               2 => word(15 downto  8),
               3 => word( 7 downto  0));
      return res4;
    elsif (word'length = 40) then
      res5 := (0 => word(39 downto 32),
               1 => word(31 downto 24),
               2 => word(23 downto 16),
               3 => word(15 downto  8),
               4 => word( 7 downto  0));
      return res5;
    elsif (word'length = 48) then
      res6 := (0 => word(47 downto 40),
               1 => word(39 downto 32),
               2 => word(31 downto 24),
               3 => word(23 downto 16),
               4 => word(15 downto  8),
               5 => word( 7 downto  0));
      return res6;
    else
      assert false
        report "stdvec_to_arr(): unsupported length of argument"
        severity failure;
      return res0;
    end if;
  end;
  
  function stdvec_to_arr2(word: std_logic_vector) return data2_arr_t is
    variable res0 : data2_arr_t(0 to -1);
    variable res1 : data2_arr_t(0 to 0);
    variable res2 : data2_arr_t(0 to 1);
    variable res3 : data2_arr_t(0 to 2);
    variable res4 : data2_arr_t(0 to 3);
    variable res5 : data2_arr_t(0 to 4);
    variable res6 : data2_arr_t(0 to 5);
  begin
    if (word'length = 16) then
      res1 := (0 => word(15 downto  0));
      return res1;
    elsif (word'length = 32) then
      res2 := (0 => word(31 downto 16),
               1 => word(15 downto  0));
      return res2;
    elsif (word'length = 48) then
      res3 := (0 => word(47 downto 32),
               1 => word(31 downto 16),
               2 => word(15 downto  0));
      return res3;
    elsif (word'length = 64) then
      res4 := (0 => word(63 downto 48),
               1 => word(47 downto 32),
               2 => word(31 downto 16),
               3 => word(15 downto  0));
      return res4;
    elsif (word'length = 80) then
      res5 := (0 => word(79 downto 64),
               1 => word(63 downto 48),
               2 => word(47 downto 32),
               3 => word(31 downto 16),
               4 => word(15 downto  0));
      return res5;
    elsif (word'length = 96) then
      res6 := (0 => word(95 downto 80),
               1 => word(79 downto 64),
               2 => word(63 downto 48),
               3 => word(47 downto 32),
               4 => word(31 downto 16),
               5 => word(15 downto  0));
      return res6;
    else
      assert false
        report "stdvec_to_arr2(): unsupported length of argument"
        severity failure;
      return res0;
    end if;
  end;

  function string_to_data_arr(s: string) return data_arr_t is
    constant len_c : natural := s'length;
    variable res : data_arr_t(0 to len_c-1);
    variable j : natural := 0;
  begin
    for i in s'left to s'right loop
      res(j) := std_logic_vector(to_unsigned(character'pos(s(i)), 8));
      j := j+1;
    end loop;
    return res;
  end;

  function max_gen_len(a: axis_gen_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).len > max then
        max := a(i).len;
      end if;
    end loop;
    return max;
  end;

  function max_gen_rate(a: axis_gen_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).rate > max then
        max := a(i).rate;
      end if;
    end loop;
    return max;
  end;

  function max_gen_wait_clks(a: axis_gen_param_arr_t) return natural is
    variable max : natural := 0;
  begin
    for i in a'left to a'right loop
      if a(i).wait_clks > max then
        max := a(i).wait_clks;
      end if;
    end loop;
    return max;
  end;

  function max_gen_test_id(a: axis_gen_param_arr_t) return natural is
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
