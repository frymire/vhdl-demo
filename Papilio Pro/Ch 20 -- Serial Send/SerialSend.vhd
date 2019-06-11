
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SerialSend is
	Port(
		clock32: in std_logic;
		JOY_SELECT_n: in std_logic;
		switches: in std_logic_vector(7 downto 0);
		TX: out std_logic;
		LEDs: out std_logic_vector(7 downto 0);
		Seg7_AN: out std_logic_vector(3 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_DP: out std_logic
	);
end SerialSend;

architecture Behavioral of SerialSend is

	signal counter: std_logic_vector(12 downto 0) := (others => '0');

	type LETTER_TYPE is array(integer range <>) of std_logic_vector(7 downto 0);
	constant NUM_LETTERS: integer := 5;
	constant LETTERS: LETTER_TYPE(0 to (NUM_LETTERS - 1)) := (
		x"48", -- H
		x"65", -- e
		x"6C", -- l
		x"6C", -- l
		x"6F"  -- o
	);

	signal letterIndex: integer := 0;
	constant REG_SIZE: integer := 10; -- 8 data bits plus one start bit and one stop bit.

	function padIt(byte: in std_logic_vector(7 downto 0)) return std_logic_vector is
	begin
		return '1' & byte & '0';     
   end function padIt;	

--	TYPE character_array is array(integer range <>) of character;
--	constant hello: character_array := "Hello";
	
--	function padIt(c: in character) return STD_LOGIC_VECTOR is
--	begin		
--		return '1' & std_logic_vector(to_unsigned(character'pos(c), 8)) & '0'; -- doesn't synthesize  
-- end function padIt;	

	signal busyShiftReg: std_logic_vector((REG_SIZE - 1) downto 0) := (others => '0');
	signal dataShiftReg: std_logic_vector((REG_SIZE - 1) downto 0) := padIt(LETTERS(letterIndex));
	
begin

	TX <= dataShiftReg(0);
	
	-- TODO: Set up FSM to debounce the button.

	process(clock32, JOY_SELECT_n, counter, busyShiftReg, dataShiftReg) begin
	
		if rising_edge(clock32) then
		
			if (letterIndex > (NUM_LETTERS + 2)) then
				letterIndex <= 0;
			end if;
		
			if (busyShiftReg(0) = '0') and (((letterIndex = 0) and (JOY_SELECT_n = '0')) or (letterIndex > 0)) then
			
				busyShiftReg <= (others => '1');
				counter <= (others => '0');
				letterIndex <= letterIndex + 1;

				case letterIndex IS
					when 0 to (NUM_LETTERS - 1) =>
						dataShiftReg <= padIt(LETTERS(letterIndex));
					when NUM_LETTERS =>
						dataShiftReg <= padIt(switches);
					when (NUM_LETTERS + 1) =>
						dataShiftReg <= padIt(x"0D"); -- \r
					when (NUM_LETTERS + 2) =>
						dataShiftReg <= padIt(x"0A"); -- \n
					when OTHERS =>
						NULL;
				end case;
				
			else
				if counter = 3332 then
					busyShiftReg <= '0' & busyShiftReg((REG_SIZE - 1) downto 1);
					dataShiftReg <= '1' & dataShiftReg((REG_SIZE - 1) downto 1);
					counter <= (others => '0');
				else
					counter <= counter + 1;
				end if;			
			end if;
					
		end if;
		
	end process;
	
	LEDs <= switches;
	
	Seg7_AN <= (others => '1');
	Seg7 <= (others => '1');
	Seg7_DP <= '1';
	
end Behavioral;
