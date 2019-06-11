library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity FlashyLights is
	Port(
		clock: in STD_LOGIC;
		switches: in STD_LOGIC_VECTOR(7 downto 0);
		LEDs: out STD_LOGIC_VECTOR(7 downto 0);
		Seg7_AN: out STD_LOGIC_VECTOR(3 downto 0);
		Seg7: out STD_LOGIC_VECTOR(6 downto 0);
		Seg7_DP: out STD_LOGIC;
		Audio: out STD_LOGIC
	);
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
	
	COMPONENT multiplier
		PORT(
			clk: IN STD_LOGIC;
			a: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			b: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			p: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;	
	
	COMPONENT dac8
		PORT(
			clock: IN std_logic;
			Data: IN std_logic_vector(7 downto 0);          
			PulseStream: OUT std_logic
		);
	END COMPONENT;
	
	signal count: STD_LOGIC_VECTOR(29 DOWNTO 0);
	signal memoryOut: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal product: STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

	LEDs <= switches;

	addr_counter: counter30 PORT MAP (
		clk => clock,
		q => count
	);
  
	rom_memory: memory PORT MAP (
		clka => clock,
		addra => count(16 DOWNTO 7),
		douta => memoryOut
	);
	
	volumeMultiplier : multiplier PORT MAP (
		clk => clock,
		a => switches,
		b => memoryOut,
		p => product
	);
		
	theDAC: dac8 PORT MAP(
		clock => clock,
		Data => product(15 DOWNTO 8),
		PulseStream => Audio
	);

	Seg7_AN <= "1111";
	Seg7 <= "1111111";
	Seg7_DP <= '1';

end Behavioral;
