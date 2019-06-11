library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity FiniteStateMachine is
	Port(
		clock: in STD_LOGIC;
		switches: in STD_LOGIC_VECTOR(7 downto 0);
		LEDs: out STD_LOGIC_VECTOR(7 downto 0);
		Seg7_AN: out STD_LOGIC_VECTOR(3 downto 0);
		Seg7: out STD_LOGIC_VECTOR(6 downto 0);
		Seg7_DP: out STD_LOGIC
	);
end FiniteStateMachine;

architecture Behavioral of FiniteStateMachine is

	constant state_error: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	constant state_start: STD_LOGIC_VECTOR(3 downto 0) := "0001";
	constant state_one_right: STD_LOGIC_VECTOR(3 downto 0) := "0010";
	constant state_two_right: STD_LOGIC_VECTOR(3 downto 0) := "0011";
	constant state_three_right: STD_LOGIC_VECTOR(3 downto 0) := "0100";
	constant state_open: STD_LOGIC_VECTOR(3 downto 0) := "0101";
	
	signal state: STD_LOGIC_VECTOR(3 downto 0) := state_error;
	
	component myDCM port(
	  CLK_IN1: in std_logic; -- Clock in ports
	  CLK_OUT1: out std_logic; -- Clock out ports
	  LOCKED: out std_logic -- Status and control signals
	 );
	end component;	
	
	signal clock16: STD_LOGIC;
	signal locked: STD_LOGIC := '0';

begin

	myClock16: myDCM port map(
		CLK_IN1 => clock,
		CLK_OUT1 => clock16,
		LOCKED => locked
	);

	LEDs(3 downto 0) <= state;

	theProcess: process(clock16, state)
		begin
			if rising_edge(clock16) then
				case state is
				
					when state_error =>
						Seg7_AN <= "1110";
						Seg7 <= "0110000";
						LEDs(7 downto 4) <= "0000";
						case switches is
							when "00000000" => state <= state_start;
							when others => state <= state_error;
						end case;
					
					when state_start =>
						Seg7_AN <= "1111";
						LEDs(7 downto 4) <= "0000";
						case switches is
							when "00000000" => state <= state_start;
							when "10000000" => state <= state_one_right;
							when others => state <= state_error;
						end case;

					when state_one_right =>
						LEDs(7 downto 4) <= "1000";
						case switches is
							when "00000000" => state <= state_one_right; -- debounce
							when "10000000" => state <= state_one_right;
							when "11000000" => state <= state_two_right;
							when others => state <= state_error;
						end case;

					when state_two_right =>
						LEDs(7 downto 4) <= "1100";					
						case switches is
							when "10000000" => state <= state_two_right; -- debounce
							when "11000000" => state <= state_two_right;
							when "11100000" => state <= state_three_right;
							when others => state <= state_error;
						end case;
		
					when state_three_right =>
						LEDs(7 downto 4) <= "1110";					
						case switches is
							when "11000000" => state <= state_three_right; -- debounce
							when "11100000" => state <= state_three_right;
							when "11110000" => state <= state_open;
							when others => state <= state_error;
						end case;
		
					when state_open =>
						Seg7_AN <= "1110";
						Seg7 <= "1001111";
						LEDs(7 downto 4) <= "1111";
						case switches is
							when "00000000" => state <= state_start;
							when others => state <= state_open;
						end case;
						
					when others =>
						state <= state_error;

				end case; -- state				
			end if; -- rising_edge(clock)
		end process;

		Seg7_DP <= '1';
			
end Behavioral;
