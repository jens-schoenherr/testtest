----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library htwdd_ds;
use htwdd_ds.integer_fcn_pkg.all;
use htwdd_ds.axis_pkg.all;

package axis_fifo_pkg is

  component axis_fifo is
    generic (
          fifo_depth_g : positive := 16;     -- >= 1
          async_rst_g  : boolean := false;
          active_rst_g : std_logic := '0'
        );
    port (
          clk_i        : in  std_logic;
          rst_n_i      : in  std_logic;

          -- axis slave
          axis_s_i     : in  axis_m2s_b1i0d0u0_t;
          axis_s_o     : out axis_s2m_t;

          -- axis master
          axis_m_i     : in  axis_s2m_t;
          axis_m_o     : out axis_m2s_b1i0d0u0_t;

          data_count_o : out std_logic_vector(unsigned_num_bits(fifo_depth_g)-1 downto 0)
        );
  end component;

  component axis_fifo_b2 is
    generic (
          fifo_depth_g : positive := 16;     -- >= 1
          async_rst_g  : boolean := false;
          active_rst_g : std_logic := '0'
        );
    port (
          clk_i        : in  std_logic;
          rst_n_i      : in  std_logic;

          -- axis slave
          axis_s_i     : in  axis_m2s_b2i0d0u0_t;
          axis_s_o     : out axis_s2m_t;

          -- axis master
          axis_m_i     : in  axis_s2m_t;
          axis_m_o     : out axis_m2s_b2i0d0u0_t;

          data_count_o : out std_logic_vector(unsigned_num_bits(fifo_depth_g)-1 downto 0)
        );
  end component;

end package axis_fifo_pkg;

package body axis_fifo_pkg is
end package body;
