----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library htwdd_ds;
use htwdd_ds.axis_pkg.all;
 
entity axis_reg is

  generic (
    async_rst_g  : boolean := false;
    active_rst_g : std_logic
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

end axis_reg;

architecture rtl of axis_reg is

  type reg_t is record
    m_transfer : std_logic;
    emptied    : std_logic;
    s_transfer : std_logic;
    axis_m_out : axis_m2s_b1i0d0u0_t;
    axis_s_out : axis_s2m_t;
  end record;
  constant dflt_reg_c : reg_t := (
    m_transfer => '0',
    emptied    => '0',
    s_transfer => '0',
    axis_m_out => dflt_axis_m2s_b1i0d0u0_c,
    axis_s_out => dflt_axis_s2m_c
  );

  signal rin, r : reg_t := dflt_reg_c;

begin

  comb: process(r, axis_s_i, axis_m_i)
    variable v: reg_t;
  begin
    v := r;
    
    v.m_transfer := v.axis_m_out.tvalid and axis_m_i.tready;      -- transfer at output (master) (i.e. output register is full)
    v.emptied    := (not v.axis_m_out.tvalid) or -- output (master) register is empty
                     v.m_transfer;               -- output (master) register is full and transfer at output (master)

    v.axis_s_out.tready := v.emptied;             -- slave i/f ready iff output register is empty (or become empty now)
    v.s_transfer := axis_s_i.tvalid and v.axis_s_out.tready;  -- output register is empty (i.e. tready=1 at slave i/f)
                                                              --   and valid at slave i/f <--> transfer at slave i/f
    if (v.s_transfer = '1') then
      v.axis_m_out.tdata  := axis_s_i.tdata;
      v.axis_m_out.tstrb  := axis_s_i.tstrb;
      v.axis_m_out.tkeep  := axis_s_i.tkeep;
      v.axis_m_out.tlast  := axis_s_i.tlast;
    end if;
    
    v.axis_m_out.tvalid := v.s_transfer or                               -- transfer at slave i/f to output reg(s)
                          (v.axis_m_out.tvalid and not axis_m_i.tready); -- output register (master) full and no transfer at output
    
    axis_s_o        <= v.axis_s_out;
    axis_m_o        <= r.axis_m_out;
    
    rin <= v;
  end process;

  reg: process (rst_n_i, clk_i)
  begin
    if rst_n_i = active_rst_g and async_rst_g then
      r <= dflt_reg_c;
    else
      if rising_edge(clk_i) then
        if rst_n_i = active_rst_g and not async_rst_g then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process;

end rtl;
