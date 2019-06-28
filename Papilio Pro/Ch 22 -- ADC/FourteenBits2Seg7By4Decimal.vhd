library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FourteenBits2Seg7By4Decimal is
	Port(
		clock: in std_logic;
		FourteenBits: in std_logic_vector(13 downto 0);
		Decimals: in std_logic_vector(3 downto 0);
		Seg7_AN: out std_logic_vector(3 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_DP: out std_logic
	);
end FourteenBits2Seg7By4Decimal;

architecture Behavioral of FourteenBits2Seg7By4Decimal is

	signal seg7Counter: std_logic_vector(15 downto 0) := (others => '0');
	
	signal quotient1000: std_logic_vector(13 downto 0) := (others => '0');
	signal remainder1000: std_logic_vector(13 downto 0) := (others => '0');
	signal rfd1000: std_logic;

	signal quotient100: std_logic_vector(13 downto 0) := (others => '0');
	signal remainder100: std_logic_vector(13 downto 0) := (others => '0');
	signal rfd100: std_logic;

	signal quotient10: std_logic_vector(13 downto 0) := (others => '0');
	signal remainder10: std_logic_vector(13 downto 0) := (others => '0');
	signal rfd10: std_logic;
	
	component divide
		port(
			clk: in std_logic;
			rfd: out std_logic;
			dividend: in std_logic_vector(13 downto 0);
			divisor: in std_logic_vector(13 downto 0);
			quotient: out std_logic_vector(13 downto 0);
			fractional: out std_logic_vector(13 downto 0)
		);
	end component;
	
	function fourBits2SSD(fourBits: in std_logic_vector(3 downto 0)) return std_logic_vector is
		variable output: std_logic_vector(6 downto 0);		
	begin	
		case fourBits is
			when "0000" => output := "0000001"; -- 0
			when "0001" => output := "1001111"; -- 1
			when "0010" => output := "0010010"; -- 2
			when "0011" => output := "0000110"; -- 3
			when "0100" => output := "1001100"; -- 4
			when "0101" => output := "0100100"; -- 5
			when "0110" => output := "0100000"; -- 6
			when "0111" => output := "0001111"; -- 7
			when "1000" => output := "0000000"; -- 8
			when "1001" => output := "0000100"; -- 9
			when others => output := "0110000"; -- E
		end case;	
		return output;     
   end function fourBits2SSD;	

begin

	process(clock) begin
		if rising_edge(clock) then		
			seg7Counter <= seg7Counter + 1;
		end if;
	end process;
		
	DivideBy1000: divide port map (
		clk => clock,
		rfd => rfd1000,
		dividend => FourteenBits,
		divisor => "00001111101000", -- 1000
		quotient => quotient1000,
		fractional => remainder1000
	);

	DivideBy100: divide port map (
		clk => clock,
		rfd => rfd100,
		dividend => remainder1000,
		divisor => "00000001100100", -- 100
		quotient => quotient100,
		fractional => remainder100
	);

	DivideBy10: divide port map (
		clk => clock,
		rfd => rfd10,
		dividend => remainder100,
		divisor => "00000000001010", -- 10
		quotient => quotient10,
		fractional => remainder10
	);
	
	seg7_process: process(seg7Counter) begin
	
		CASE seg7Counter(15 downto 14) IS
			WHEN "11" =>
				Seg7_AN <= "0111";
				Seg7 <= fourBits2SSD(quotient1000(3 downto 0));
				Seg7_DP <= Decimals(3);
			WHEN "10" =>
				Seg7_AN <= "1011";
				Seg7 <= fourBits2SSD(quotient100(3 downto 0));
				Seg7_DP <= '1';
				Seg7_DP <= Decimals(2);
			WHEN "01" =>
				Seg7_AN <= "1101";
				Seg7 <= fourBits2SSD(quotient10(3 downto 0));
				Seg7_DP <= '1';
				Seg7_DP <= Decimals(1);
			WHEN "00" =>
				Seg7_AN <= "1110";
				Seg7 <= fourBits2SSD(remainder10(3 downto 0));
				Seg7_DP <= '1';
				Seg7_DP <= Decimals(0);
			WHEN OTHERS =>
				Seg7_AN <= "1111";
				Seg7 <= "1111111";
				Seg7_DP <= '1';
		END CASE;

	end process;
	
end Behavioral;
