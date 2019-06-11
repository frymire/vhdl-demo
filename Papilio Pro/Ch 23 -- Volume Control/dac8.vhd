library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dac8 is
	Port(
		clock: in STD_LOGIC;
		Data: in STD_LOGIC_VECTOR (7 downto 0);
		PulseStream: out STD_LOGIC
	);
end dac8;

architecture Behavioral of dac8 is
	signal sum: STD_LOGIC_VECTOR(8 downto 0);
begin

	PulseStream <= sum(8);
	
	process(clock, sum)
	begin
		if rising_edge(clock) then
			sum <= ("0" & sum(7 downto 0)) + ("0" &Data);
		end if;
	end process;

end Behavioral;
