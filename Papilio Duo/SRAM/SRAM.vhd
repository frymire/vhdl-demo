
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SRAM is
	Port(
		clock32: in std_logic;
		Switches: in std_logic_vector(7 downto 0);
		UP: in std_logic;
		DOWN: in std_logic;
		LEFT: in std_logic;
		RIGHT: in std_logic;
		SRAM_CE_n: out std_logic;
		SRAM_WE_n: out std_logic;
		SRAM_OE_n: out std_logic;
		SRAM_ADDR: out std_logic_vector(20 downto 0);
		SRAM_DATA: inout std_logic_vector(7 downto 0);
		LEDs: out std_logic_vector(7 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_AN: out std_logic_vector(4 downto 0);
		Seg7_DP: out std_logic
	);
end SRAM;

architecture Behavioral of SRAM is

	constant letterX: std_logic_vector(7 downto 0) := "01011000";
	constant letterY: std_logic_vector(7 downto 0) := "01011001";
	constant letterZ: std_logic_vector(7 downto 0) := "01011010";
	signal dataFromSRAM: std_logic_vector(7 downto 0) := (others => '0');

	type stateType is (idle, w0, r0); 
	signal state: stateType := idle;

	signal buttons: std_logic_vector(3 downto 0) := (others => '0');
	
begin

	SRAM_CE_n <= '0'; -- chip not disabled
	SRAM_OE_n <= '0'; -- output not disabled
	
	SRAM_ADDR <= "0000000000000" & Switches(7 downto 0);
	
	buttons <= UP & DOWN & LEFT & RIGHT;

	process(clock32) begin
		if rising_edge(clock32) then

			case state is
			
				when idle =>
				
					case buttons is
					
						when "0010" => -- Left button, write an X...
							SRAM_WE_n <= '0';
							LEDs <= letterX;
							SRAM_DATA <= letterX;
							state <= w0;							

						when "1000" => -- Up button, write a Y...
							SRAM_WE_n <= '0';
							LEDs <= letterY;
							SRAM_DATA <= letterY;
							state <= w0;							

						when "0001" => -- Right button, write a Z...
							SRAM_WE_n <= '0';
							LEDs <= letterZ;
							SRAM_DATA <= letterZ;
							state <= w0;							

						when "0100" => -- Down button, read...
							LEDs <= "00000000";
							state <= r0;
					
						when others => -- Display received data
							LEDs <= dataFromSRAM;
							state <= idle;
							
					end case;
						
				-- Write Cycle (#3) --
				
				when w0 =>
					SRAM_WE_n <= '1';
					SRAM_DATA <= "ZZZZZZZZ";
					state <= idle;
					
				-- Read Cycle (#1) --
				
				when r0 =>
					dataFromSRAM <= SRAM_DATA;
					state <= idle;
					
			end case;
		
		end if;
	end process;
	
	Seg7_AN <= (others => '1');
	Seg7 <= (others => '1');
	Seg7_DP <= '1';

end Behavioral;
