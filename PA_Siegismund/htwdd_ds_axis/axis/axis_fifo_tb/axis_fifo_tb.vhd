----------------------------------------------------------------------------------
-- Author: Jens Schoenherr
--         HTW Dresden
----------------------------------------------------------------------------------

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library htwdd_ds;
use htwdd_ds.tb_utils_2008_pkg.all;
use htwdd_ds.integer_fcn_pkg.all;
use htwdd_ds.pck_fio_1993.all;
use htwdd_ds.image_ieee_pkg.all;
use htwdd_ds.axis_pkg.all;
use htwdd_ds.axis_fifo_pkg.all;
use htwdd_ds.axis_fifo_tb_pkg.all;
use htwdd_ds.axis_data_gen_pkg.all;
use htwdd_ds.axis_data_cmp_pkg.all;

entity axis_fifo_tb is
  generic (
    fifo_depth_g   : positive  := 16;
    auto_repeat_g  : boolean := false
  );

end entity axis_fifo_tb;

architecture behavior of axis_fifo_tb is
    
  -- DUT ports
  signal clk_in         : std_logic := '0';
  signal rst_n_in       : std_logic;
  
  signal axis_gen_m2s     : axis_m2s_b1i0d0u0_t;
  signal axis_gen_s2m     : axis_s2m_t;
  
  signal axis_cmp_m2s     : axis_m2s_b1i0d0u0_t;
  signal axis_cmp_s2m     : axis_s2m_t;
  
  signal axis_gen_transfer : std_logic;
  signal axis_cmp_transfer : std_logic;

  signal data_count_out : unsigned(unsigned_num_bits(fifo_depth_g)-1 downto 0);
 
  -- TB helper
  constant me_c               : string := axis_fifo_tb'path_name;
  constant clk_half_periode_c : time := 10 ns; -- i.e. 50 MHz
 
  constant severity_c : severity_level := failure;
  --constant severity_c : severity_level := error;
  
  signal finish               : std_logic := '0';
  signal gen_done_out         : std_logic; 
  signal cmp_data_over_out    : std_logic;
  signal cmp_deviation_out    : std_logic;
  
begin
  
  -----------------------------------------------------------------------------
  -- Device under test (DUT)
  -----------------------------------------------------------------------------
  dut : axis_fifo
      generic map (
        fifo_depth_g   => fifo_depth_g
      )
      port map (
        clk_i        => clk_in,
        rst_n_i      => rst_n_in,
        
        -- axis slave
        axis_s_i     => axis_gen_m2s,
        axis_s_o     => axis_gen_s2m,
        
        -- axis master
        axis_m_i     => axis_cmp_s2m,
        axis_m_o     => axis_cmp_m2s,

        unsigned(data_count_o)   => data_count_out
     );
  
  -----------------------------------------------------------------------------
  -- testbench control
  -----------------------------------------------------------------------------
 
  end_proc : process is
    variable l: line;
  begin
    fprint (output, l, "%s: fifo_depth_g   :  %s\n", me_c, integer'image(fifo_depth_g));
    if auto_repeat_g then
      wait until finish = '1'; -- last pattern to simulate
      wait_clk(clk_in, 10);
    else
      wait until gen_done_out = '1';
      wait_clk(clk_in, 10);
      assert cmp_data_over_out = '1'
        report "Some data at axis_gen_cmp are missing." severity failure;   
    end if;
    end_sim(me_c);
    wait;
  end process;
  
  gen_finish : process (clk_in, rst_n_in) is -- only for auto_repeat_g = true
    variable init_cnt : natural := 0;
  begin
    if rst_n_in = '0' then
      init_cnt := 0;
      finish <= '0';
    elsif rising_edge(clk_in) then
      if init_cnt > 1000 then -- 10 us
        finish <= '1';
      else
        init_cnt := init_cnt + 1;
      end if;
    end if;
  end process gen_finish;
 
  -----------------------------------------------------------------------------
  -- testsignal generation
  -----------------------------------------------------------------------------
  rst_n_in <= '0', '1' after gsr_time_c + 9*clk_half_periode_c;

  clk_in <= not clk_in after clk_half_periode_c;

  data_gen_i0 : axis_data_gen
    generic map (
      auto_repeat_g     => auto_repeat_g,
      axis_gen_params_g => axis_gen_params_c,
      data_arr_g        => data_arr_c
    )
    port map (
      clk_i        => clk_in,
      rst_n_i      => rst_n_in,
            
      -- axis master i/f
      data_i       => axis_gen_s2m,
      data_o       => axis_gen_m2s,
      
      done_o       => gen_done_out

    );
    
  -----------------------------------------------------------------------------
  -- signal evaluation
  -----------------------------------------------------------------------------

  data_cmp_i0 : axis_data_cmp
    generic map (
      auto_repeat_g     => auto_repeat_g,
      ready_at_end_g    => -1, -- no ready at end
      axis_cmp_params_g => axis_cmp_params_c,
      data_arr_g        => data_arr_c
    )
    port map (
      clk_i        => clk_in,
      rst_n_i      => rst_n_in,
            
      -- axis slave i/f
      data_i       => axis_cmp_m2s,
      data_o       => axis_cmp_s2m,
      
      deviation_o  => cmp_deviation_out,
      data_over_o  => cmp_data_over_out

    );

  -- check output of axis_data_cmp
  check_proc : process (clk_in) is
  begin
    if falling_edge(clk_in) then
      assert cmp_deviation_out = '0'
        report me_c & "Deviation at axis_data_cmp." severity failure;
    end if;
  end process;
  
  -- just for visualization in testbench
  axis_gen_transfer <= axis_gen_m2s.tvalid and axis_gen_s2m.tready;
  axis_cmp_transfer <= axis_cmp_m2s.tvalid and axis_cmp_s2m.tready;

end architecture behavior;

