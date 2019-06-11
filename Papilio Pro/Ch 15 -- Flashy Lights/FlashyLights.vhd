library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity FlashyLights is
	Port(
		clock: in STD_LOGIC;
		LEDs: out STD_LOGIC_VECTOR(7 downto 0));
end FlashyLights;

architecture Behavioral of FlashyLights is

	COMPONENT counter30
		PORT(
			clk: IN STD_LOGIC;
			q: OUT STD_LOGIC_VECTOR(29 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT memory
		PORT(
			clka: IN STD_LOGIC;
			addra: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			douta: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;	
	
	signal count: STD_LOGIC_VECTOR(29 DOWNTO 0);

begin

	addr_counter: counter30
		PORT MAP (
			clk => clock,
			q => count
		);
  
	rom_memory: memory
		PORT MAP (
			clka => clock,
			addra => count(29 DOWNTO 20),
			douta => LEDs
		);
		
end Behavioral;

-- This will only flash lights for about 1 sec after start, and then periodically thereafter.
