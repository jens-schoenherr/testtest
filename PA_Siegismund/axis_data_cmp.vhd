----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--library htwdd_ds;
use work.axis_pkg.all;
use work.axis_data_cmp_pkg.all;
use work.axis_data_gen_pkg.all;
use work.integer_fcn_pkg.all;

entity axis_data_cmp is
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
end axis_data_cmp;

architecture rtl of axis_data_cmp is

  constant num_cmp_params_c : natural := axis_cmp_params_g'length;

  constant axis_cmp_params_c : axis_cmp_param_arr_t(0 to num_cmp_params_c-1)  := axis_cmp_params_g;
  constant data_arr_c        : data_arr_t              (0 to data_arr_g'length-1) := data_arr_g;
  constant data_arr_rnd_c    : data_arr_t              (0 to data_arr_g'length-1) := data_arr_g; ----------------------------------------------

  constant len_wdt_c     : natural := unsigned_num_bits(max_cmp_len      (axis_cmp_params_c));
  constant rate_wdt_c    : natural := unsigned_num_bits(max_cmp_rate     (axis_cmp_params_c));
  constant wait_wdt_c    : natural := unsigned_num_bits(max_cmp_wait_clks(axis_cmp_params_c));
  constant test_id_wdt_c : natural := unsigned_num_bits(max_cmp_test_id  (axis_cmp_params_c));

  constant act_cnt_wdt_c  : natural := unsigned_num_bits(axis_cmp_params_c'length);
  constant data_cnt_wdt_c : natural := unsigned_num_bits(data_arr_rnd_c'length); -------------------------------------------------------data_arr_c
  constant pkt_cnt_wdt_c  : natural := data_cnt_wdt_c;
  constant dev_wdt_c      : natural := 5;

  type state_t is (waiting, ready, pause);
  type reg_t is record
    state        : state_t;
    wait_cnt     : unsigned(wait_wdt_c-1 downto 0);
    act_cnt      : unsigned(act_cnt_wdt_c-1 downto 0);
    rate_cnt     : unsigned(rate_wdt_c-1 downto 0);
    data_cnt     : unsigned(data_cnt_wdt_c-1 downto 0);
    pkt_cnt      : unsigned(data_cnt_wdt_c-1 downto 0);
    data_out     : axis_s2m_t;
    dev_out      : std_logic_vector(dev_wdt_c-1 downto 0);
    over_out     : std_logic;
  end record;
  constant dflt_reg_c : reg_t := (
    state        => waiting,
    wait_cnt     => to_unsigned(axis_cmp_params_c(0).wait_clks-1, wait_wdt_c),
    act_cnt      => to_unsigned(0, act_cnt_wdt_c),
    rate_cnt     => to_unsigned(0, rate_wdt_c),
    data_cnt     => to_unsigned(0, data_cnt_wdt_c),
    pkt_cnt      => to_unsigned(0, data_cnt_wdt_c),
    data_out     => dflt_axis_s2m_c,
    dev_out      => (others => '0'),
    over_out     => '0'
  );

  signal rin, r : reg_t := dflt_reg_c;

begin

  comb: process (r, data_i)
    variable v: reg_t;
    variable rate_wait: boolean;
    variable wait_wait: boolean;
	
	
	
  begin
    
	
	v := r;

    rate_wait := false;
    wait_wait := false;
    case v.state is
    when waiting => wait_wait := true;
    when ready   => -- compare
                    if (r.data_out.tready = '1' and data_i.tvalid = '1') then
                      if (data_i.tkeep = "1") then   -- VHDL 2008: if (and data_i.tkeep) = '1' then
                        if (data_i.tstrb = "1") then -- VHDL 2008: if (and data_i.tstrb) = '1' then
                          -- data byte
                          if (v.data_cnt = data_arr_rnd_c'length) then ---------------------------------------------------data_arr_c
                            v.dev_out(0) := '1';
                          else
                            if (data_i.tdata /= data_arr_rnd_c(to_integer(v.data_cnt))) then -----------------------data_arr_c(to_integer(v.data_cnt))------------------------
                              v.dev_out(1) := '1';
                            end if;
                            v.data_cnt := v.data_cnt + 1;
                            v.pkt_cnt  := v.pkt_cnt + 1;
                          end if;
                        else
                          -- position byte
                          -- !still not supported
                        end if;
                      else
                        -- null bytes are not compared
                      end if;
                      if (data_i.tlast = '1') then
                        if v.act_cnt = axis_cmp_params_c'length then
                          v.dev_out(2) := '1';
                        else
                          if (v.pkt_cnt /= axis_cmp_params_c(to_integer(v.act_cnt)).len) then
                            v.dev_out(3) := '1';
                          end if;
                          if v.act_cnt = axis_cmp_params_c'high then
                            if auto_repeat_g then
                              v.act_cnt  := to_unsigned(0, act_cnt_wdt_c); -- start from beginning
                              v.data_cnt := to_unsigned(0, data_cnt_wdt_c);
                              v.wait_cnt := to_unsigned(axis_cmp_params_c(to_integer(v.act_cnt)).wait_clks, wait_wdt_c);
                            else
                              v.act_cnt  := v.act_cnt + 1;
                              v.over_out := '1';
                              if ready_at_end_g < 0 then
                                v.wait_cnt := to_unsigned(0, wait_wdt_c);
                              else
                                v.wait_cnt := to_unsigned(ready_at_end_g, wait_wdt_c);
                              end if;
                            end if;
                          else
                            v.act_cnt  := v.act_cnt + 1;
                            v.wait_cnt := to_unsigned(axis_cmp_params_c(to_integer(v.act_cnt)).wait_clks, wait_wdt_c);
                          end if;
                          v.pkt_cnt := to_unsigned(0, data_cnt_wdt_c);
                          wait_wait := true;
                        end if;
                      else -- if data_i.tlast = '1'
                        -- This condition is wrong. It is allowed to send tlast after the last data word in a separate transfer.
                        -- If tlast would be omitted/forgotten then data_over_o would remain 0.
                        -- if (or_reduce(v.dev_out) = '0') then
                          -- if (v.pkt_cnt = axis_cmp_params_c(to_integer(v.act_cnt)).len) then
                            -- v.dev_out(5) := '1';
                          -- end if;
                        -- end if;
                        rate_wait := true;
                      end if;
                    end if;
    when pause   => rate_wait := true;

    end case;

    if (rate_wait) then
      if v.rate_cnt = 0 then
        v.state           := ready;
        v.data_out.tready := '1';
        if (v.act_cnt /= axis_cmp_params_c'length) then
          v.rate_cnt      := to_unsigned(axis_cmp_params_c(to_integer(v.act_cnt)).rate, rate_wdt_c);
        else
          v.rate_cnt      := to_unsigned(0, rate_wdt_c);
        end if;
      else
        v.state           := pause;
        v.data_out.tready := '0';
        v.rate_cnt        := v.rate_cnt - 1;
      end if;
    end if;

    if (wait_wait) then
      v.data_out.tready := '0';
      v.state := waiting;
      if v.wait_cnt = 0 then
        if (v.act_cnt /= axis_cmp_params_c'length) then
          v.data_out.tready := '1';
          v.state           := ready;
          v.rate_cnt        := to_unsigned(axis_cmp_params_c(to_integer(v.act_cnt)).rate, rate_wdt_c);
        elsif (ready_at_end_g >= 0) then
          v.data_out.tready := '1';
          v.state           := ready;
          v.rate_cnt        := to_unsigned(0, rate_wdt_c);
        end if;
      else
        v.wait_cnt := v.wait_cnt - 1;
      end if;
    end if;

    if (r.over_out = '1') then
      if (data_i.tvalid = '1') then
        v.dev_out(4) := '1';
      end if;
    end if;

    data_o      <= r.data_out;
    deviation_o <= or_reduce(r.dev_out);
    data_over_o <= r.over_out;

    rin <= v;
  end process;

  reg: process (clk_i, rst_n_i)
  begin
    if rst_n_i = active_rst_g and async_rst_g then
      r <= dflt_reg_c;
    else
      if rising_edge(clk_i) then
        if rst_n_i = active_rst_g and not async_rst_g then
          r <= dflt_reg_c;
        else
          r <= rin;
          assert rin.dev_out(0) = '0'
            report "Received more data than in the reference data." severity warning;
          assert rin.dev_out(1) = '0'
            report "Wrong data." severity warning;
          assert rin.dev_out(2) = '0'
            report "Additional tlast after last packet." severity warning;
          assert rin.dev_out(3) = '0'
            report "Packet too short. Too less data at tlast." severity warning;
          assert rin.dev_out(4) = '0'
            report "Data provided (tvalid=1) after last reference data. (tready='0' from now on.)" severity warning;
          -- assert r.dev_out(5) = '0'
            -- report "Data of packet arrived but still no tlast." severity warning;
          assert rin.act_cnt = r.act_cnt
            report "Received packet " & integer'image(to_integer(r.act_cnt)) & " " & kind_g severity note;
        end if;
      end if;
    end if;
  end process;

end rtl;
