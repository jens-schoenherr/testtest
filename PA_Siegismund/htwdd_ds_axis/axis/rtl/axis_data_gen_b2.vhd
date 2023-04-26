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
use htwdd_ds.axis_data_gen_pkg.all;
use htwdd_ds.integer_fcn_pkg.all;

entity axis_data_gen_b2 is
  generic (
    auto_repeat_g         : boolean := true;
    axis_gen_params_g : axis_gen_param_arr_t := empty_axis_gen_param_c;
    data_arr_g            : data2_arr_t;
    kind_g                : string := "";
    async_rst_g           : boolean;
    active_rst_g          : std_logic
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
end axis_data_gen_b2;

architecture rtl of axis_data_gen_b2 is

  constant num_gen_params_c : natural := axis_gen_params_g'length;

  constant axis_gen_params_c : axis_gen_param_arr_t(0 to num_gen_params_c-1)  := axis_gen_params_g;
  constant data_arr_c        : data2_arr_t             (0 to data_arr_g'length-1) := data_arr_g;

  constant len_wdt_c     : natural := unsigned_num_bits(max_gen_len      (axis_gen_params_c));
  constant rate_wdt_c    : natural := unsigned_num_bits(max_gen_rate     (axis_gen_params_c));
  constant wait_wdt_c    : natural := unsigned_num_bits(max_gen_wait_clks(axis_gen_params_c));
  constant test_id_wdt_c : natural := unsigned_num_bits(max_gen_test_id  (axis_gen_params_c));

  constant act_cnt_wdt_c  : natural := unsigned_num_bits(axis_gen_params_c'length);
  constant data_cnt_wdt_c : natural := unsigned_num_bits(data_arr_c'length);
  constant pkt_cnt_wdt_c  : natural := data_cnt_wdt_c;

  type state_t is (waiting, send, pause);
  type reg_t is record
    state        : state_t;
    wait_cnt     : unsigned(wait_wdt_c-1 downto 0);
    act_cnt      : unsigned(act_cnt_wdt_c-1 downto 0);
    rate_cnt     : unsigned(rate_wdt_c-1 downto 0);
    data_cnt     : unsigned(data_cnt_wdt_c-1 downto 0);
    pkt_cnt      : unsigned(data_cnt_wdt_c-1 downto 0);
    first        : std_logic;
    data_out     : axis_m2s_b2i0d0u0_t;
    done_out     : std_logic;
    test_id_out  : unsigned(test_id_wdt_c-1 downto 0);
  end record;
  constant dflt_reg_c : reg_t := (
    state        => waiting,
    wait_cnt     => to_unsigned(axis_gen_params_c(0).wait_clks-1, wait_wdt_c),
    act_cnt      => to_unsigned(0, act_cnt_wdt_c),
    rate_cnt     => to_unsigned(0, rate_wdt_c),
    data_cnt     => to_unsigned(0, data_cnt_wdt_c),
    pkt_cnt      => to_unsigned(0, data_cnt_wdt_c),
    first        => '0',
    data_out     => dflt_axis_m2s_b2i0d0u0_c,
    done_out     => '0',
    test_id_out  => to_unsigned(0, test_id_wdt_c)
  );

  signal rin, r : reg_t := dflt_reg_c;

begin

  comb: process (r, data_i)
    variable v: reg_t;
    variable rate_wait: boolean;
    variable wait_wait: boolean;
  begin
    v := r;

    v.data_out.tvalid := '0';
    v.data_out.tlast  := '0';
    v.data_out.tstrb  := (others => '0');
    v.data_out.tkeep  := (others => '0');
    v.first           := '0';
    rate_wait := false;
    wait_wait := false;
    case (v.state) is
    when waiting =>   wait_wait := true;
    when send =>      if (data_i.tready = '1') then
                        v.data_cnt := v.data_cnt + 1; -- next data
                        if (v.pkt_cnt = axis_gen_params_c(to_integer(v.act_cnt)).len-1) then
                          v.pkt_cnt  := to_unsigned(0, data_cnt_wdt_c);
                          if v.act_cnt = axis_gen_params_c'high then -- all actions done
                            if auto_repeat_g then
                              v.act_cnt  := to_unsigned(0, act_cnt_wdt_c); -- start from beginning
                              v.data_cnt := to_unsigned(0, data_cnt_wdt_c);
                              v.wait_cnt := to_unsigned(axis_gen_params_c(to_integer(v.act_cnt)).wait_clks, wait_wdt_c);
                            else
                              v.act_cnt  := v.act_cnt + 1;
                              v.data_cnt := to_unsigned(0, data_cnt_wdt_c);
                              v.wait_cnt := to_unsigned(0, wait_wdt_c);
                              v.done_out := '1';
                            end if;
                          else -- not all actions done --> do next action
                            v.act_cnt  := v.act_cnt + 1;
                            v.wait_cnt := to_unsigned(axis_gen_params_c(to_integer(v.act_cnt)).wait_clks, wait_wdt_c);
                          end if;
                          wait_wait := true;
                        else -- if v.pkt_cnt = axis_gen_params_c(to_integer(v.act_cnt)).len-1)
                          -- send next word because the current one is not the last in the packet
                          v.pkt_cnt := v.pkt_cnt + 1;
                          rate_wait := true;
                        end if;
                      else -- if (data_i.tready = '1')
                        -- still trying to send
                        v.data_out.tvalid := '1';  -- output of word
                      end if;
    when pause =>     rate_wait := true;
    end case;

    if (rate_wait) then
      if v.rate_cnt = 0 then
        v.state           := send;
        v.data_out.tvalid := '1'; -- output of word
        v.rate_cnt        := to_unsigned(axis_gen_params_c(to_integer(v.act_cnt)).rate, rate_wdt_c);
      else
        v.rate_cnt        := v.rate_cnt - 1;
        v.state           := pause;
      end if;
    end if;

    if (wait_wait) then
      v.state           := waiting;
      if v.wait_cnt = 0 then
        if v.act_cnt /= axis_gen_params_c'length then
          v.state           := send;
          v.data_out.tvalid := '1';  -- output of word
          v.rate_cnt        := to_unsigned(axis_gen_params_c(to_integer(v.act_cnt)).rate, rate_wdt_c);
          v.first           := '1';
        end if;
      else
        v.wait_cnt := v.wait_cnt - 1;
      end if;
    end if;

    if (v.data_out.tvalid = '1') then -- output of the current word
      v.data_out.tdata  := data_arr_c(to_integer(v.data_cnt));
      v.data_out.tkeep  := (others => '1'); -- data byte
      v.data_out.tstrb  := (others => '1');
      if (v.pkt_cnt = to_unsigned(axis_gen_params_c(to_integer(v.act_cnt)).len-1, len_wdt_c)) then
        v.data_out.tlast := axis_gen_params_c(to_integer(v.act_cnt)).tlast;
      end if;
    else
      v.data_out.tdata := (others => '0'); -- to ensure that the data is only valid with tvalid = 1
    end if;
    if v.act_cnt /= axis_gen_params_c'length then
      v.test_id_out := to_unsigned(axis_gen_params_c(to_integer(v.act_cnt)).test_id, test_id_wdt_c);
    end if;

    data_o <= r.data_out;
    done_o <= r.done_out;
    test_id_o <= to_integer(r.test_id_out);

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
          assert rin.first = '0'
            report "Test " & integer'image(axis_gen_params_c(to_integer(rin.act_cnt)).test_id) &
                   ": Sending packet " & integer'image(to_integer(rin.act_cnt)) & " " & kind_g severity note;
        end if;
      end if;
    end if;
  end process;

end rtl;
