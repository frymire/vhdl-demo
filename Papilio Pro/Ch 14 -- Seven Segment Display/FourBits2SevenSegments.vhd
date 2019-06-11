library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FourBits2SevenSegments is
	Port(
		FourBits: in STD_LOGIC_VECTOR (3 downto 0);
		SevenSegments: out STD_LOGIC_VECTOR (6 downto 0));
end FourBits2SevenSegments;

architecture Behavioral of FourBits2SevenSegments is

begin

	seg7_process: process(FourBits)
		begin
			
			CASE FourBits IS
				WHEN "0000" => -- 0
					SevenSegments <= "0000001";
				WHEN "0001" => -- 1
					SevenSegments <= "1001111";
				WHEN "0010" => -- 2
					SevenSegments <= "0010010";
				WHEN "0011" => -- 3
					SevenSegments <= "0000110";
				WHEN "0100" => -- 4
					SevenSegments <= "1001100";
				WHEN "0101" => -- 5
					SevenSegments <= "0100100";
				WHEN "0110" => -- 6
					SevenSegments <= "0100000";
				WHEN "0111" => -- 7
					SevenSegments <= "0001111";
				WHEN "1000" => -- 8
					SevenSegments <= "0000000";
				WHEN "1001" => -- 9
					SevenSegments <= "0000100";
				WHEN "1010" => -- A
					SevenSegments <= "0001000";
				WHEN "1011" => -- B
					SevenSegments <= "1100000";
				WHEN "1100" => -- C
					SevenSegments <= "0110001";
				WHEN "1101" => -- D
					SevenSegments <= "1000010";
				WHEN "1110" => -- E
					SevenSegments <= "0110000";
				WHEN "1111" => -- F
					SevenSegments <= "0111000";
				WHEN OTHERS => -- Error
					SevenSegments <= "1111111";
			END CASE;
		
		end process;

end Behavioral;
