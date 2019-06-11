library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Division is
	Port(
		clock: in STD_LOGIC;
		switches: in STD_LOGIC_VECTOR(7 downto 0);
		LEDs: out STD_LOGIC_VECTOR(7 downto 0);
		Seg7_AN: out STD_LOGIC_VECTOR(3 downto 0);
		Seg7: out STD_LOGIC_VECTOR(6 downto 0);
		Seg7_DP: out STD_LOGIC
	);
end Division;

architecture Behavioral of Division is

	component divider port(
		clk: in std_logic;
		rfd: out std_logic;
		dividend: in std_logic_vector(3 downto 0);
		divisor: in std_logic_vector(3 downto 0);
		quotient: out std_logic_vector(3 downto 0);
		fractional: out std_logic_vector(3 downto 0));
	end component;

	signal numerator: STD_LOGIC_VECTOR(3 downto 0);
	signal denominator: STD_LOGIC_VECTOR(3 downto 0);
	signal rfd: STD_LOGIC := '0';
	
begin

	numerator <= switches(7 downto 4);
	denominator <= switches(3 downto 0);
	
	theDivider: divider port map (
		clk => clock,
		rfd => rfd,
		dividend => numerator,
		divisor => denominator,
		quotient => LEDs(7 downto 4),
		fractional => LEDs(3 downto 0)
	);	
	
--	LEDs <= numerator & denominator;
	
	Seg7_AN <= "1111";
	Seg7 <= "1111111";
	Seg7_DP <= '1';
	
end Behavioral;
