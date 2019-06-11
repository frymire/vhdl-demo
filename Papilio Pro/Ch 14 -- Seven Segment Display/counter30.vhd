library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter30 is
	Port (
		clock: in STD_LOGIC;
      enable: in STD_LOGIC;
		count: out STD_LOGIC_VECTOR (29 downto 0)
	);
end counter30;

architecture Behavioral of counter30 is
	signal counter: STD_LOGIC_VECTOR(29 downto 0) := (others => '0');
begin

	clock_process: process(clock, enable)
		begin		
			if rising_edge(clock) AND enable = '1' then
				counter <= counter + 1;
			end if;			
		end process;
		
	count <= counter;

end Behavioral;
