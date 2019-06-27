
-- NOTE: The Intro to Spartan FPGA tutorial book says connecting more than 3.3 V could damage the ADC. This
-- seems to be wrong, though. The LogicStart megawing schematic shows that the analog reference voltage is 
-- 5 V. This provided sensible voltage readings using the code below.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ADC is
	Port(
	
		clock: in std_logic;

		adc_cs_n: out std_logic;
		adc_sclk: out std_logic;
		adc_din: out std_logic;
		adc_dout: in std_logic;
		
		switches: in std_logic_vector(2 downto 0);
		LEDs: out std_logic_vector(7 downto 0);
		Seg7_AN: out std_logic_vector(3 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_DP: out std_logic
	);
end ADC;

architecture Behavioral of ADC is

	signal counter: std_logic_vector(22 downto 0) := (others => '0');
	signal clockShiftRegister: std_logic_vector(1 downto 0) := (others => '0');

	signal adcActive: std_logic;
	signal channel: std_logic_vector(2 downto 0) := (others => '0');
	signal dataIn: std_logic_vector(11 downto 0) := (others => '0');
	signal channelShiftRegister: std_logic_vector(2 downto 0) := (others => '0');
	signal dataInShiftRegister: std_logic_vector(11 downto 0) := (others => '0');
	
	signal seg7Counter: std_logic_vector(15 downto 0) := (others => '0');
	signal Seg7_1000s: std_logic_vector(6 downto 0) := (others => '0');
	signal Seg7_100s: std_logic_vector(6 downto 0) := (others => '0');
	signal Seg7_10s: std_logic_vector(6 downto 0) := (others => '0');
	signal Seg7_1s: std_logic_vector(6 downto 0) := (others => '0');
	
	COMPONENT FourBits2SevenSegments
		PORT(
			FourBits: in std_logic_vector(3 downto 0);          
			SevenSegments: out std_logic_vector(6 downto 0)
		);
	END COMPONENT;	

begin

	adc_din <= channelShiftRegister(2);
	adc_sclk <= clockShiftRegister(1);
	
	with counter(22 downto 6) select adcActive <= 
		'1' when "00000000000000000", 
		'0' when others;						

	process(clock) begin
		if rising_edge(clock) then
		
			seg7Counter <= seg7Counter + 1;
			counter <= counter + 1;		
			adc_cs_n <= not(adcActive);
				
			clockShiftRegister(1) <= clockShiftRegister(0);
			channelShiftRegister(2 downto 1) <= channelShiftRegister(1 downto 0);
			
			if adcActive = '1' then
						
				clockShiftRegister(0) <= counter(1);

				case counter(5 downto 0) is 
					when "000000" => 
						dataIn <= dataInShiftRegister; -- capture reading from previous cycle
						LEDs <= dataInShiftRegister(11 downto 4);
						channel <= switches;
					when others => NULL;
				end case; 

				case counter(5 downto 2) is
					when "0010" => channelShiftRegister(0) <= channel(2);
					when "0011" => channelShiftRegister(0) <= channel(1);
					when "0100" => channelShiftRegister(0) <= channel(0);
					when others => channelShiftRegister(0) <= '0';
				end case;
				
				if counter(1 downto 0) = "11" then
					dataInShiftRegister <= dataInShiftRegister(10 downto 0) & adc_dout;
				end if;
				
			else -- adcActive = '0'			
				clockShiftRegister(0) <= '1';
				channelShiftRegister(0) <= '0';				
			end if;
			
		end if;
		
	end process;
	
	
	-- Drive the Seg7 display...

	Inst_Seg7_1000s: FourBits2SevenSegments PORT MAP(
		FourBits => '0' & channel,
		SevenSegments => Seg7_1000s
	);
	
	Inst_Seg7_100s: FourBits2SevenSegments PORT MAP(
		FourBits => dataIn(11 downto 8),
		SevenSegments => Seg7_100s
	);

	Inst_Seg7_10s: FourBits2SevenSegments PORT MAP(
		FourBits => dataIn(7 downto 4),
		SevenSegments => Seg7_10s
	);
	
	Inst_Seg7_1s: FourBits2SevenSegments PORT MAP(
		FourBits => dataIn(3 downto 0),
		SevenSegments => Seg7_1s
	);
	
	seg7_process: process(seg7Counter) begin
	
		CASE seg7Counter(15 downto 14) IS
			WHEN "00" =>
				Seg7_AN <= "1110";
				Seg7 <= Seg7_1s;
				Seg7_DP <= not(channel(0));
			WHEN "01" =>
				Seg7_AN <= "1101";
				Seg7 <= Seg7_10s;
				Seg7_DP <= not(channel(1));
			WHEN "10" =>
				Seg7_AN <= "1011";
				Seg7 <= Seg7_100s;
				Seg7_DP <= not(channel(2));
			WHEN "11" =>
				Seg7_AN <= "0111";
				Seg7 <= Seg7_1000s;
				Seg7_DP <= '1';
			WHEN OTHERS =>
				Seg7_AN <= "1111";
				Seg7 <= "1111111";
				Seg7_DP <= '1';
		END CASE;

	end process;

end Behavioral;
