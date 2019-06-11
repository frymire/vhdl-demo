
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SerialReceive is
	Port(
		clock32: in std_logic;
		RX: in std_logic;
--		switches: in std_logic_vector(7 downto 0);
		LEDs: out std_logic_vector(7 downto 0);
		Seg7_AN: out std_logic_vector(3 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_DP: out std_logic
	);
end SerialReceive;

architecture Behavioral of SerialReceive is

	signal signalCounter: integer := 0;
	signal ledCounter: std_logic_vector(24 downto 0) := (others => '0');
	signal bits: std_logic_vector(39 downto 0) := (others => '1');
	
	-- Put these into a single buffer array and index them by ledCounter(25 downto 24)
	TYPE ByteBuffer is array(integer range <>) of std_logic_vector(7 downto 0);
	signal theBuffer: ByteBuffer(0 to 3) := (
		(others => '0'),
		(others => '0'),
		(others => '0'),
		(others => '0')
	);
	
	signal bufferIndex: integer := 0;
	signal bufferReadIndex: integer := 0;
	
	function bitsAreValid(bits: in std_logic_vector(39 downto 0)) return boolean is
	begin
		return (
			(bits(2 downto 1) = "00") and 
			(bits(6) = bits(5)) and 
			(bits(10) = bits(9)) and 
			(bits(14) = bits(13)) and 
			(bits(18) = bits(17)) and 
			(bits(22) = bits(21)) and 
			(bits(26) = bits(25)) and 
			(bits(30) = bits(29)) and 
			(bits(34) = bits(33)) and 
			(bits(38 downto 37) = "11")
		);			
   end function bitsAreValid;
	
begin

	LEDs <= theBuffer(bufferIndex);
	
	process (clock32) begin
		if rising_edge(clock32) then
		
			ledCounter <= ledCounter + 1;
		
			case ledCounter(24 downto 23) IS
				when "00" =>
					bufferIndex <= 0;
				when "01" =>
					bufferIndex <= 1;
				when "10" =>
					bufferIndex <= 2;
				when "11" =>
					bufferIndex <= 3;
				when OTHERS =>
					NULL;
			end case;
		
			if signalCounter = 833 then
			
					bits <= RX & bits(39 downto 1);

					if  bitsAreValid(bits) then
					
						theBuffer(bufferReadIndex) <= 
							bits(33) & bits(29) & bits(25) & bits(21) & bits(17) & bits(13) & bits(9) & bits(5);
						
						if (bufferReadIndex = 3) then
							bufferReadIndex <= 0;
						else
							bufferReadIndex <= bufferReadIndex + 1;
						end if;
						
						bits <= (others => '1');
						
					end if;

					signalCounter <= 0;
					
				else
					signalCounter <= signalCounter + 1;
			end if;					
			
		end if;
	end process;

	Seg7_AN <= (others => '0');
	Seg7 <= (others => '1');
	Seg7_DP <= '1';
	
end Behavioral;
