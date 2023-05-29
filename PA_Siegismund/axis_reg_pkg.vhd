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

package axis_reg_pkg is

  component axis_reg is
    generic (
      async_rst_g  : boolean := false;
      active_rst_g : std_logic := '0'
    );
    port ( 
      clk_i    : in  std_logic;
      rst_n_i  : in  std_logic;
      
      -- axis slave
      axis_s_i : in  axis_m2s_b1i0d0u0_t;
      axis_s_o : out axis_s2m_t;
      
      -- axis master
      axis_m_i : in  axis_s2m_t;
      axis_m_o : out axis_m2s_b1i0d0u0_t
    );
  end component;

end package axis_reg_pkg;

package body axis_reg_pkg is
end package body;
