library ieee;
use ieee.std_logic_1164.all;

entity ha is
	port
	(
		a: in std_ulogic;
		b: in std_ulogic;
		clk: in  std_logic;
		rnd: in  std_logic_vector(7 downto 0);
		o: out std_logic;
		c: out std_logic
		
	);
end ha;

architecture behave of ha is
begin
	o <= a xor b;
	c <= a and b;
end behave;