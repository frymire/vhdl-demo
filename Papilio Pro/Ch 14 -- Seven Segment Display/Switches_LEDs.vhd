library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Switches_LEDs is
	Port ( 
		clock: in STD_LOGIC;
		switches: in STD_LOGIC_VECTOR(7 downto 0);
      LEDs: out STD_LOGIC_VECTOR(7 downto 0); 
		Seg7_AN: out STD_LOGIC_VECTOR(3 downto 0);
		Seg7: out STD_LOGIC_VECTOR(6 downto 0);
		Seg7_DP: out STD_LOGIC
	);
end Switches_LEDs;

architecture Behavioral of Switches_LEDs is

	signal count: STD_LOGIC_VECTOR(29 downto 0) := (others => '0');
	signal Seg7_high: STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	signal Seg7_low: STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	
	COMPONENT counter30
	PORT(
		clock: IN std_logic;
		enable: IN std_logic;          
		count: OUT std_logic_vector(29 downto 0)
		);
	END COMPONENT;

	COMPONENT FourBits2SevenSegments
	PORT(
		FourBits : IN std_logic_vector(3 downto 0);          
		SevenSegments : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
begin

	Inst_counter30_0: counter30 PORT MAP(
		clock => clock,
		enable => switches(0),
		count => count
	);

	Inst_FourBits2SevenSegments_high: FourBits2SevenSegments PORT MAP(
		FourBits => count(29 downto 26),
		SevenSegments => Seg7_high
	);
	
	Inst_FourBits2SevenSegments_low: FourBits2SevenSegments PORT MAP(
		FourBits => count(25 downto 22),
		SevenSegments => Seg7_low
	);		

	LEDs <= count(29 downto 22);
	
	seg7_process: process(count)
		begin
		l
			CASE count(15 downto 14) IS
				WHEN "00" =>
					Seg7_AN <= "1110";
					Seg7 <= Seg7_low;
				WHEN "01" =>
					Seg7_AN <= "1101";
					Seg7 <= Seg7_high;
				WHEN "10" =>
					Seg7_AN <= "1011";
					Seg7 <= Seg7_low;
				WHEN "11" =>
					Seg7_AN <= "0111";
					Seg7 <= Seg7_high;
				WHEN OTHERS =>
					Seg7_AN <= "1111";
					Seg7 <= Seg7_high;
			END CASE;

			Seg7_DP <= '1';
		
		end process;
	
end Behavioral;
