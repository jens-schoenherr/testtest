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
use work.axis_reg_pkg.all;
use work.axis_data_gen_pkg.all;
use work.axis_data_cmp_pkg.all;
use work.axis_reg_tb_pkg.all;
use work.integer_fcn_pkg.all;
use work.tb_utils_2008_pkg.all;
use work.txt_util.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity axis_reg_tb is
  generic (
    auto_repeat_g : boolean := false
  );
end entity axis_reg_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------

architecture behavior of axis_reg_tb is

  -----------------------------------------------------------------------------
  -- components
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- constants
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- signals
  -----------------------------------------------------------------------------

  -- Inputs
  signal clk_in          : std_logic := '1';
  signal rst_n_in        : std_logic;

  -- AXIS
  signal axis_gen_m2s     : axis_m2s_b1i0d0u0_t;
  signal axis_gen_s2m     : axis_s2m_t;
  
  signal axis_cmp_m2s     : axis_m2s_b1i0d0u0_t;
  signal axis_cmp_s2m     : axis_s2m_t;
  signal axis_cmp_s2m_tready : std_logic;
  signal axis_cmp_m2s_tvalid : std_logic;
  signal axis_gen_s2m_tready : std_logic;
  signal axis_gen_m2s_tvalid : std_logic;
  signal axis_gen_m2s_tdata : std_logic_vector(7 downto 0);
  signal axis_cmp_m2s_tdata : std_logic_vector(7 downto 0);
  
  signal axis_gen_transfer : std_logic;
  signal axis_cmp_transfer : std_logic;
  
  -- TB helper
  constant me_c               : string := axis_reg_tb'path_name;
  constant clk_half_periode_c : time := 5 ns; -- i.e. 100 MHz
  
  signal finish               : std_logic := '0';
  signal gen_done_out         : std_logic; 
  signal cmp_data_over_out    : std_logic;
  signal cmp_deviation_out    : std_logic;
  
begin  -- architecture testbench

  -----------------------------------------------------------------------------
  -- Device under test (DUT)
  -----------------------------------------------------------------------------
  dut : axis_reg
    port map (
      clk_i        => clk_in,
      rst_n_i      => rst_n_in,
            
      -- axis slave
      axis_s_i     => axis_gen_m2s,
      axis_s_o     => axis_gen_s2m,
      
      -- axis master
      axis_m_i     => axis_cmp_s2m,
      axis_m_o     => axis_cmp_m2s
      
    );
    
  -----------------------------------------------------------------------------
  -- testbench control
  -----------------------------------------------------------------------------

  gen_finish : process (clk_in, rst_n_in) is
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

  end_proc : process is
  begin
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

  -----------------------------------------------------------------------------
  -- testsignal generation
  -----------------------------------------------------------------------------

  rst_n_in <= '0', '1' after gsr_time_c + 9*clk_half_periode_c;

  clk_in <= not clk_in after clk_half_periode_c;

  data_gen_i0 : axis_data_gen
    generic map (
      auto_repeat_g     => auto_repeat_g,
      axis_gen_params_g => axis_gen_params_c,
      data_arr_g        => data_arr_rnd_c--data_arr_c -----------------------------------------------------?
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
      data_arr_g        => data_arr_rnd_c --data_arr_c---------------------------------------------------?
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

  axis_cmp_s2m_tready <= axis_cmp_s2m.tready;
  axis_cmp_m2s_tvalid <= axis_cmp_m2s.tvalid;	-- master tvalid
  axis_gen_s2m_tready <= axis_gen_s2m.tready;	-- slave tready
  axis_gen_m2s_tvalid <= axis_gen_m2s.tvalid;
  axis_gen_m2s_tdata <= axis_gen_m2s.tdata;		--data out master
  axis_cmp_m2s_tdata <= axis_cmp_m2s.tdata; 	-- data in slave
  
end architecture behavior;

