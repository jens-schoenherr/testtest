----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

package axis_pkg is

  type axis_m2s_b1i0d0u0_t is record
      tvalid   : std_logic;
      tdata    : std_logic_vector(7 downto 0);
      tstrb    : std_logic_vector(0 downto 0);  -- 1 per byte of tdata
      tkeep    : std_logic_vector(0 downto 0);  -- 1 per byte of tdata
      tlast    : std_logic;
      --tid      : std_logic_vector(0 downto 1);
      --tdest    : std_logic_vector(0 downto 1);
      --tuser    : std_logic_vector(0 downto 1);
  end record;
  constant dflt_axis_m2s_b1i0d0u0_c : axis_m2s_b1i0d0u0_t := (
      tvalid   => '0',
      tdata    => (others => '0'),
      tstrb    => (others => '0'),
      tkeep    => (others => '0'),
      tlast    => '0'--,
      --tid      => (others => '0'),
      --tdest    => (others => '0'),
      --tuser    => (others => '0')
    );

  type axis_m2s_b2i0d0u0_t is record
      tvalid   : std_logic;
      tdata    : std_logic_vector(15 downto 0);
      tstrb    : std_logic_vector(1 downto 0);  -- 1 per byte of tdata
      tkeep    : std_logic_vector(1 downto 0);  -- 1 per byte of tdata
      tlast    : std_logic;
      --tid      : std_logic_vector(0 downto 1);
      --tdest    : std_logic_vector(0 downto 1);
      --tuser    : std_logic_vector(0 downto 1);
  end record;
  constant dflt_axis_m2s_b2i0d0u0_c : axis_m2s_b2i0d0u0_t := (
      tvalid   => '0',
      tdata    => (others => '0'),
      tstrb    => (others => '0'),
      tkeep    => (others => '0'),
      tlast    => '0'--,
      --tid      => (others => '0'),
      --tdest    => (others => '0'),
      --tuser    => (others => '0')
    );

  type axis_s2m_t is record
      tready   : std_logic;
  end record;
  constant dflt_axis_s2m_c : axis_s2m_t := (
      tready   => '0'
    );
  constant ready_axis_s2m_c : axis_s2m_t := (
      tready   => '1'
    );

  type axis_m2s_b1i0d0u0_arr_t is array (natural range <>) of axis_m2s_b1i0d0u0_t;
  --constant dflt_axis_m2s_b1i0d0u0_arr_c : axis_m2s_b1i0d0u0_arr_t := (others => dflt_axis_m2s_b1i0d0u0_c);

  type axis_m2s_b2i0d0u0_arr_t is array (natural range <>) of axis_m2s_b2i0d0u0_t;
  --constant dflt_axis_m2s_b2i0d0u0_arr_c : axis_m2s_b2i0d0u0_arr_t := (others => dflt_axis_m2s_b2i0d0u0_c);

  type axis_s2m_arr_t is array (natural range <>) of axis_s2m_t;
  --constant dflt_axis_s2m_arr_c : axis_s2m_arr_t := (others => dflt_axis_s2m_c);


end package axis_pkg;

package body axis_pkg is
end package body axis_pkg;
