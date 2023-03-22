----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- package declaration
-------------------------------------------------------------------------------

package integer_fcn_pkg is
  
  -----------------------------------------------------------------------------
  -- functions
  -----------------------------------------------------------------------------
    
  function max (a, b: integer) return integer;
  function min (a, b: integer) return integer;
    
  -- returns the number of bits needed to represent x as signed number
  -- (Use only for constant/generic calculation!)
  function signed_num_bits (x: integer) return positive;

  -- returns the number of bits needed to represent x as unsigned number
  -- (Use only for constant/generic calculation!)
  function unsigned_num_bits (x: natural) return positive;

  -- returns the number of bits needed to represent an unsigned decimal number with x digits
  -- (Use only for constant/generic calculation!)
  function unsigned_dec_num_bits (x: positive) return positive;

  -- returns the number of decimal digits (dets) needed to represent an unsigned number with x bits
  -- (Use only for constant/generic calculation!)
  function unsigned_bin_num_dets (x: positive) return positive;

  -- adds two bcd digits (i.e. 4-bit-vectors) and one bit
  -- returns two bcd digits: 1 bit (MSB) for the 10th digit and 4 bit (LSBs)
  function add_bcd_digit(a: std_logic_vector; b: std_logic_vector; c: std_logic; version: natural := 1) return std_logic_vector;

  -- adds two bcd numbers
  -- returns a bcd number: 1 bit (MSB) for the "overflow" digit and the others for the sum
  -- result contains max(next_4(a'length), next_4(b'length)) + 1 bits
  function add_bcd(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;

  -- converts a binary number 'a' to bcd encoding
  -- a: number to be converted
  -- result contains 4*unsigned_bin_num_dets(a'length) bits
  function bin_to_bcd(a: unsigned) return std_logic_vector;
end;
 
package body integer_fcn_pkg is

  -- like in ieee.numeric_std (body)
  function max (a, b: integer) return integer is
  begin
    if a > b then
      return a;
    else
      return b;
    end if;
  end max;

  function min (a, b: integer) return integer is
  begin
    if a < b then
      return a;
    else
      return b;
    end if;
  end min;

  -- calculates the number of bits needed to represent x as an signed number
  -- verified with log2_tb
  function signed_num_bits (x: integer) return positive is
    variable nbits: natural;
    variable n: natural;
  begin
    if x >= 0 then
      n := x;
    else
      n := -(x+1);
    end if;
    nbits := 1;
    while n > 0 loop
      nbits := nbits+1;
      n := n / 2;
    end loop;
    return nbits;
  end signed_num_bits;

  -- calculates the number of bits needed to represent x as an unsigned number
  -- verified with log2_tb
  function unsigned_num_bits (x: natural) return positive is
    variable nbits: natural;
    variable n: natural;
  begin
    n := x;
    nbits := 1;
    while n > 1 loop
      nbits := nbits+1;
      n := n / 2;
    end loop;
    return nbits;
  end unsigned_num_bits;

  -- verified with bcd_tb
  function unsigned_dec_num_bits (x: positive) return positive is
    constant fact_den : natural := 3322; -- fact_den/fact_nom = log_2 10 = ln 10/ln 2 = 3.32192805...
    constant fact_nom : natural := 1000; -- fact_den is rounded up
    variable nbits    : natural;
  begin
    nbits := (x*fact_den+fact_nom-1) / fact_nom;
    return nbits;
  end unsigned_dec_num_bits;

  -- verified with bcd_tb
  function unsigned_bin_num_dets (x: positive) return positive is
    variable ndets    : natural;
    constant fact_den : natural := 33219; -- fact_den/fact_nom = log_2 10 = ln 10/ln 2 = 3.32192805...
    constant fact_nom : natural := 10000; -- fact_den is rounded down
  begin
    ndets := (x*fact_nom+fact_den-1) / fact_den;
    return ndets;
  end unsigned_bin_num_dets;
  -- verified with bcd_tb
  function add_bcd_digit(a: std_logic_vector; b: std_logic_vector; c: std_logic; version: natural := 1) return std_logic_vector is
    variable res: unsigned(4 downto 0);
    variable c_u: unsigned(1 downto 0) := '0' & c;
  begin
    assert a'length = 4
      report "add_bcd_digit(): operand a is not a 4-bit vector"
      severity failure;
    assert b'length = 4
      report "add_bcd_digit(): operand b is not a 4-bit vector"
      severity failure;
    assert unsigned(a) <= 9
      report "add_bcd_digit(): operand a is not a bcd digit (> 9)"
      severity error;
    assert unsigned(b) <= 9
      report "add_bcd_digit(): operand b is not a bcd digit (> 9)"
      severity error;
    if (version = 1) then
      res := resize(unsigned(a), 5) + resize(unsigned(b), 5) + c_u + to_unsigned(6, 5);
      if (res(4) = '0') then -- if (res < 16) then
        res := res - 6;
      end if;
    else -- version 0
      res := resize(unsigned(a), 5) + resize(unsigned(b), 5) + c_u;
      if (res(4 downto 1) >= 5) then -- if (res >= 10) then
        res := res + 6;
      end if;
    end if;
    return std_logic_vector(res);
  end function;

  -- verified with bcd_tb
  function next_4(n: natural) return natural is
    variable res: natural;
  begin
    res := n + ((4 - (n mod 4)) mod 4);
    return res;      
  end function;

  -- verified with bcd_tb
  function add_bcd(a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
    variable res_width : positive := max(next_4(a'length), next_4(b'length)) + 1;
    variable a_width   : positive := res_width-1;
    variable b_width   : positive := res_width-1;
    variable a_ext     : std_logic_vector(a_width-1 downto 0) := (others => '0');
    variable b_ext     : std_logic_vector(b_width-1 downto 0) := (others => '0');
    variable res       : std_logic_vector(res_width-1 downto 0) := (others => '0');
    variable iter      : positive := a_width / 4;
    variable bcd_sum   : std_logic_vector(4 downto 0) := (others => '0');
  begin
    a_ext(a'length-1 downto 0) := a;
    b_ext(b'length-1 downto 0) := b;
    for i in 0 to iter-1 loop
      bcd_sum := add_bcd_digit(a_ext(4*i+3 downto 4*i),
                               b_ext(4*i+3 downto 4*i),
                               bcd_sum(4));
      res(4*i+3 downto 4*i) := bcd_sum(3 downto 0);
    end loop;
    res(res'left) := bcd_sum(4);
    return res;
  end function;

  -- verified with bcd_tb
  function bin_to_bcd(a: unsigned) return std_logic_vector is
    constant n_dets_c  : natural := unsigned_bin_num_dets(a'length);
    constant r_width_c : natural := 4*n_dets_c;
    variable a_v       : unsigned(a'length-1 downto 0) := a;
    variable dec       : std_logic_vector(r_width_c-1 downto 0) := (others => '0');
    variable dec_tmp   : std_logic_vector(r_width_c   downto 0);
    variable res       : std_logic_vector(r_width_c-1 downto 0) := (others => '0');
    variable res_tmp   : std_logic_vector(r_width_c   downto 0) := (others => '0');
  begin
    dec    := (others => '0');
    dec(0) := '1'; -- dec = 1 (BCD)
    for i in a_v'right to a_v'left loop
      if (a_v(i) = '1') then
        res_tmp := add_bcd(res, dec);
      end if;
      res     := res_tmp(res'left downto res'right); -- drop MSB
      dec_tmp := add_bcd(dec, dec);                  -- dec := 2*dec = 2^i
      dec     := dec_tmp(dec'left downto dec'right); -- drop MSB
    end loop;
    return res;
  end function;

end;
