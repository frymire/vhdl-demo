
-- NOTE: The Intro to Spartan FPGA tutorial book says connecting more than 3.3 V could damage the ADC. The 
-- LogicStart megawing schematic, however, shows that the analog reference voltage is 5 V. This provided 
-- sensible voltage readings using the code below, and didn't seem to cause any damage.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

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
	
	type AnalogReadingType is array(integer range <>) of std_logic_vector(11 downto 0);
	signal analogReading: AnalogReadingType(0 to 7) := (others => (others => '0'));
	
	signal channelShiftRegister: std_logic_vector(2 downto 0) := (others => '0');
	signal dataInShiftRegister: std_logic_vector(11 downto 0) := (others => '0');

	component FourteenBits2Seg7By4Decimal
		Port(
			clock: in std_logic;
			FourteenBits: in std_logic_vector(13 downto 0);
			Decimals: in std_logic_vector(3 downto 0);
			Seg7_AN: out std_logic_vector(3 downto 0);
			Seg7: out std_logic_vector(6 downto 0);
			Seg7_DP: out std_logic
		);
	end component;

begin

	adc_din <= channelShiftRegister(2);
	adc_sclk <= clockShiftRegister(1);
	
	with counter(22 downto 9) select adcActive <= 
		'1' when "00000000000000", 
		'0' when others;						

	process(clock, switches, counter, channel) begin
		if rising_edge(clock) then
		
			counter <= counter + 1;		
			adc_cs_n <= not(adcActive);
			
			LEDs <= analogReading(to_integer(unsigned(switches)))(11 downto 4);		
				
			clockShiftRegister(1) <= clockShiftRegister(0);
			channelShiftRegister(2 downto 1) <= channelShiftRegister(1 downto 0);
			
			if adcActive = '1' then
						
				clockShiftRegister(0) <= counter(1);

				if counter(5 downto 0) = "000000" then
				
					channel <= counter(8 downto 6);
					
					-- capture reading from previous cycle
					analogReading(to_integer(unsigned(channel) - 1)) <= dataInShiftRegister;
					
				end if;

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
	
	Seg7Decimal: FourteenBits2Seg7By4Decimal port map (
		clock => clock,
		FourteenBits => "00" & analogReading(to_integer(unsigned(switches))),
		Decimals => "1" & not(switches),
		Seg7_AN => Seg7_AN,
		Seg7 => Seg7,
		Seg7_DP => Seg7_DP
	);

end Behavioral;
