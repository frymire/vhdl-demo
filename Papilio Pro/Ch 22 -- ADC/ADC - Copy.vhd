library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ADC is
	Port(
	
		clock: in std_logic;

		ADC_CS_N: out std_logic;
		ADC_SCLK: out std_logic;
		ADC_DIN: out std_logic;
		ADC_DOUT: in std_logic;
		
		switches: in std_logic_vector(2 downto 0);
		LEDs: out std_logic_vector(7 downto 0);
		Seg7_AN: out std_logic_vector(3 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_DP: out std_logic
	);
end ADC;

architecture Behavioral of ADC is

	signal counter: std_logic_vector(22 downto 0) := (others => '0');
	signal clk_shiftreg: std_logic_vector(1 downto 0) := (others => '0');
	signal dataout_shiftreg: std_logic_vector(2 downto 0) := (others => '0');
	signal datain_shiftreg: std_logic_vector(11 downto 0) := (others => '0');
	signal channel_hold: std_logic_vector(2 downto 0) := (others => '0');
	signal adc_active: std_logic;

begin

	adc_din <= dataout_shiftreg(2);
	adc_sclk <= clk_shiftreg(1);
	
	with counter(22 downto 6) select adc_active <= 
		'1' when "00000000000000000", 
		'0' when others;						

	process(clock) begin
		if rising_edge(clock) then
		
			counter <= counter + 1;		
				
			clk_shiftreg(1) <= clk_shiftreg(0);
			adc_cs_n <= not(adc_active);
			
			if adc_active = '1' then
				clk_shiftreg(0) <= counter(1);
			else
				clk_shiftreg(0) <= '1';
			end if;
			
			dataout_shiftreg(2 downto 1) <= dataout_shiftreg(1 downto 0);
			
			if adc_active = '1' then
						
				case counter(5 downto 2) is
					when "0010" => dataout_shiftreg(0) <= channel_hold(2);
					when "0011" => dataout_shiftreg(0) <= channel_hold(1);
					when "0100" => dataout_shiftreg(0) <= channel_hold(0);
					when others => dataout_shiftreg(0) <= '0';
				end case;
				
				if counter(5 downto 0) = "000000" then
					channel_hold <= switches;
				end if;
				
				if counter(1 downto 0) = "11" then
					datain_shiftreg <= datain_shiftreg(10 downto 0) & adc_dout;
				end if;
				
				if counter(5 downto 0) = "111111" then
					LEDs <= datain_shiftreg(10 downto 3);
				end if;
				
			else -- adc_active = '0'			
				dataout_shiftreg(0) <= '0';				
			end if;
			
		end if;
		
	end process;

	Seg7_AN <= "1110";
	Seg7 <= not(switches) & "1111";
	Seg7_DP <= '1';

end Behavioral;
