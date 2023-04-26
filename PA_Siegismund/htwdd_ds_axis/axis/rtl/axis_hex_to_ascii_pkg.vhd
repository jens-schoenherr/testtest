----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library htwdd_ds;
use htwdd_ds.axis_pkg.all;

package axis_hex_to_ascii_pkg is

  type last_act_t is (none, cr, crlf);
  type base_t is (hex, dec);

  component axis_hex_to_ascii is
    generic (
      capital_letters_g : boolean := true;
      base_g            : base_t := hex;
      last_act_g        : last_act_t := none;
      async_rst_g       : boolean := false;
      active_rst_g      : std_logic := '0'
    );
    port ( 
          clk_i        : in  std_logic;
          rst_n_i      : in  std_logic;

          -- data input - axis slave
          axis_s_i     : in  axis_m2s_b1i0d0u0_t;
          axis_s_o     : out axis_s2m_t;
          
          -- data output - axis master
          axis_m_i     : in  axis_s2m_t;
          axis_m_o     : out axis_m2s_b1i0d0u0_t
         );
  end component;

end package axis_hex_to_ascii_pkg;

package body axis_hex_to_ascii_pkg is
end package body;
