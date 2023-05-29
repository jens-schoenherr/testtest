----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library htwdd_ds;
use htwdd_ds.axis_pkg.all;
use htwdd_ds.integer_fcn_pkg.all;
use htwdd_ds.axis_hex_to_ascii_pkg.all;

entity axis_hex_to_ascii is
  generic (
    capital_letters_g : boolean;
    base_g            : base_t := hex;
    last_act_g        : last_act_t := none;
    async_rst_g       : boolean := false;
    active_rst_g      : std_logic
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

end axis_hex_to_ascii;

architecture rtl of axis_hex_to_ascii is
  
  type state_t is (high_nibble, middle_nibble, low_nibble, cr, lf);
  type reg_t is record
    state      : state_t;
    data_in    : std_logic_vector(3 downto 0);
    last_in    : std_logic;
    convert    : std_logic;
    to_convert : std_logic_vector(3 downto 0);
    bcd        : std_logic_vector(11 downto 0);
    m_transfer : std_logic;
    emptied    : std_logic;
    s_transfer : std_logic;
    axis_m_out : axis_m2s_b1i0d0u0_t;
    axis_s_out : axis_s2m_t;
  end record;
  constant dflt_reg_c : reg_t := (
    state      => high_nibble,
    data_in    => (others => '0'),
    last_in    => '0',
    convert    => '0',
    to_convert => (others => '0'),
    bcd        => (others => '0'),
    m_transfer => '0',
    emptied    => '0',
    s_transfer => '0',
    axis_m_out => dflt_axis_m2s_b1i0d0u0_c,
    axis_s_out => dflt_axis_s2m_c
  );
  signal rin, r: reg_t := dflt_reg_c;
  
begin
  
  comb: process (r, axis_s_i, axis_m_i) is
  variable v: reg_t;
  begin
    v := r;
    
    v.m_transfer := r.axis_m_out.tvalid and axis_m_i.tready;
    v.emptied := (not v.axis_m_out.tvalid) or      -- output register is empty
                      v.m_transfer;                -- output register is full and transfer at output

    v.axis_s_out.tready := '0';
    if v.state = high_nibble and v.emptied = '1' then
      v.axis_s_out.tready := '1';
    end if;
    
    v.s_transfer := axis_s_i.tvalid and v.axis_s_out.tready;

    v.axis_m_out.tvalid := (v.axis_m_out.tvalid and not axis_m_i.tready); -- output register full and no transfer at output
    v.axis_m_out.tkeep  := (others => '1');
    v.axis_m_out.tstrb  := (others => '1');

    v.convert := '0';
    v.to_convert := (others => '0');
    
    case v.state is
    when high_nibble =>
      if v.s_transfer = '1' and v.emptied = '1' then
        if (axis_s_i.tkeep = "1") then
          if (axis_s_i.tstrb = "1") then
            v.last_in    := axis_s_i.tlast;
            v.data_in    := axis_s_i.tdata(3 downto 0);
            v.to_convert := axis_s_i.tdata(7 downto 4);
            v.convert    := '1';
            v.axis_m_out.tlast  := '0';
            v.axis_m_out.tvalid := '1';
            if base_g = hex then
              v.state := low_nibble;
            else -- dec
              v.state := middle_nibble;
              v.bcd        := bin_to_bcd(unsigned(axis_s_i.tdata));
              v.to_convert := v.bcd(11 downto 8);
            end if;
          else
            -- position byte
            -- !still not supported
          end if;
        else
          -- null bytes are ignored
        end if;
      end if;
    when middle_nibble => -- only for base_g = dec
      if v.emptied = '1' then
        v.to_convert        := v.bcd(7 downto 4);
        v.convert           := '1';
        v.axis_m_out.tvalid := '1';
        v.axis_m_out.tlast  := '0';
        v.state             := low_nibble;
      end if;
    when low_nibble =>
      if v.emptied = '1' then
        if base_g = hex then
          v.to_convert        := v.data_in;
        else -- dec
          v.to_convert        := v.bcd(3 downto 0);
        end if;
        v.convert           := '1';
        v.axis_m_out.tvalid := '1';
        if last_act_g = none or v.last_in = '0' then
          v.axis_m_out.tlast  := v.last_in;
          v.state             := high_nibble;
        else
          -- last_act_g /= none and v.last_in = 1
          v.axis_m_out.tlast  := '0';
          v.state             := cr;
        end if;
      end if;
    when cr =>
      if v.emptied = '1' then
        v.axis_m_out.tvalid := '1';
        v.axis_m_out.tdata  := x"0d"; -- cr
        if last_act_g = crlf then
          v.axis_m_out.tlast  := '0';
          v.state             := lf;
        else
          v.axis_m_out.tlast  := '1';
          v.state             := high_nibble;
        end if;
      end if;
    when lf =>
      if v.emptied = '1' then
        v.axis_m_out.tvalid := '1';
        v.axis_m_out.tdata  := x"0a"; -- lf
        v.axis_m_out.tlast  := '1';
        v.state             := high_nibble;
      end if;
    end case;
    
    if (v.convert = '1') then
      if base_g = hex then
        if (unsigned(v.to_convert) < 10) then
          v.axis_m_out.tdata := x"3" & v.to_convert; -- numbers
        else
          v.axis_m_out.tdata := (others => '0');
          v.axis_m_out.tdata(3 downto 0) := v.to_convert;
          if capital_letters_g then
            v.axis_m_out.tdata := std_logic_vector(unsigned(v.axis_m_out.tdata) + 55);      -- capital letters
          else
            v.axis_m_out.tdata := std_logic_vector(unsigned(v.axis_m_out.tdata) + 55 + 32); -- small letters
          end if;
        end if;
      else -- dec
        v.axis_m_out.tdata := x"3" & v.to_convert; -- numbers
      end if;
    end if;
    
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
