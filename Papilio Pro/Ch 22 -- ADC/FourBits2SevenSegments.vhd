library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FourBits2SevenSegments is
	Port(
		FourBits: in STD_LOGIC_VECTOR(3 downto 0);
		SevenSegments: out STD_LOGIC_VECTOR(6 downto 0)
	);
end FourBits2SevenSegments;

architecture Behavioral of FourBits2SevenSegments is

begin

	seg7_process: process(FourBits)
		begin
			
			CASE FourBits IS
				WHEN "0000" => SevenSegments <= "0000001"; -- 0
				WHEN "0001" => SevenSegments <= "1001111"; -- 1
				WHEN "0010" => SevenSegments <= "0010010"; -- 2
				WHEN "0011" => SevenSegments <= "0000110"; -- 3
				WHEN "0100" => SevenSegments <= "1001100"; -- 4
				WHEN "0101" => SevenSegments <= "0100100"; -- 5
				WHEN "0110" => SevenSegments <= "0100000"; -- 6
				WHEN "0111" => SevenSegments <= "0001111"; -- 7
				WHEN "1000" => SevenSegments <= "0000000"; -- 8
				WHEN "1001" => SevenSegments <= "0000100"; -- 9
				WHEN OTHERS => SevenSegments <= "0110000"; -- E
			END CASE;
		
		end process;

end Behavioral;
