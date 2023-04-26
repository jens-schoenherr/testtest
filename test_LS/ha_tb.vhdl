library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
  --use uvvm_util.types_pkg.all;
  --use uvvm_util.global_signals_and_shared_variables_pkg.all;
  --use uvvm_util.hierarchy_linked_list_pkg.all;
  --use uvvm_util.string_methods_pkg.all;
  --use uvvm_util.adaptations_pkg.all;
  --use uvvm_util.methods_pkg.all;
  --use uvvm_util.bfm_common_pkg.all;
  --use uvvm_util.alert_hierarchy_pkg.all;
  --use uvvm_util.license_pkg.all;
  --use uvvm_util.protected_types_pkg.all;
  --use uvvm_util.rand_pkg.all;
  --use uvvm_util.func_cov_pkg.all;
  context uvvm_util.uvvm_util_context;
  
--library bitvis_uart;

--library uvvm_vvc_framework;
--use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

--library bitvis_vip_sbi;
--context bitvis_vip_sbi.vvc_context;

--library bitvis_vip_uart;
--context bitvis_vip_uart.vvc_context;

entity ha_tb is
end ha_tb;

architecture test of ha_tb is

constant C_CLK_PERIOD   : time    := 10 ns;
--constant GC_SEED1 : integer := 10;
--constant GC_SEED2 : integer := 15;


	component ha
		port
		(
			a: in std_ulogic;
			b: in std_ulogic;
			clk: in  std_logic;
			rnd: in std_logic_vector(7 downto 0);
			o: out std_logic;
			c: out std_logic
		);
	end component;
	
	signal a_tb, b_tb, o_tb, c_tb : std_ulogic;
	signal clk         : std_logic := '0';
	signal clk_ena     : boolean   := false;
	signal rnd   	   : std_logic_vector(7 downto 0) := "00000000";
	
begin
	half_adder: ha port map (a => a_tb, b => b_tb, o => o_tb, c => c_tb, clk   => clk, rnd => rnd);
	
	clock_generator(clk, clk_ena, C_CLK_PERIOD, "Core clock");	-- Fkt. zur Generierung eines Clock-Signals
	
	
	process 
	
	variable rnd_val : std_logic_vector(7 downto 0);
	
	begin
	randomize(10, 15);	-- Funktion aus uvvm_util mit der die sog. Seeds für die random() Fkt. generiert werden. Wenn Seeds (Zahlen in der Klammer) nicht geändert werden erhält man von der random() Fkt. immer wieder die gleiche Folge
	
		log(ID_LOG_HDR, "Start simulation");
		
		clk_ena <= true;
		wait for 5 * C_CLK_PERIOD;
		
		for i in 0 to 10 loop
		rnd_val := random(rnd_val'length);		-- Fkt. zur Generierung der "Zufallsfolge"
		rnd <= rnd_val;
		wait for 10 ns; 
		end loop;
		
		a_tb <= 'X';
		b_tb <= 'X';
		wait for 1 ns;
		
		a_tb <= '0';
		b_tb <= '0';
		wait for 1 ns;
		
		a_tb <= '0';
		b_tb <= '1';
		wait for 1 ns;
		
		a_tb <= '1';
		b_tb <= '0';
		wait for 1 ns;
		
		a_tb <= '1';
		b_tb <= '1';
		wait for 1 ns;
		
	
		
		clk_ena <= false;
		
		assert false report "Reached end of test";
		wait;
		
	end process;
	
end test;