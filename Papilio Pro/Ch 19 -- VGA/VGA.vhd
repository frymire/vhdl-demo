
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is 
	Port(
		clock32: in STD_LOGIC;
		VGA_VSYNC: out STD_LOGIC;
		VGA_HSYNC: out STD_LOGIC;
		VGA_RED: out STD_LOGIC_VECTOR(2 downto 0);
		VGA_GREEN: out STD_LOGIC_VECTOR(2 downto 0);
		VGA_BLUE: out STD_LOGIC_VECTOR(1 downto 0);
		Seg7_AN: out STD_LOGIC_VECTOR(3 downto 0);
		Seg7: out STD_LOGIC_VECTOR(6 downto 0);
		Seg7_DP: out STD_LOGIC		
	);
end VGA;

architecture Behavioral of VGA is

	component clock25 
		port(
			CLK_IN1: in std_logic;
			CLK_OUT1: out std_logic
		);
	end component;
	
	signal clk25: std_logic;
	
	signal count: std_logic_vector(26 downto 0) := (others => '0');
	signal hCount: std_logic_vector(9 downto 0) := (others => '0');
	signal vCount: std_logic_vector(9 downto 0) := (others => '0');
	
	shared variable redValue: STD_LOGIC_VECTOR(2 downto 0);
	shared variable greenValue: STD_LOGIC_VECTOR(2 downto 0);
	shared variable blueValue: STD_LOGIC_VECTOR(1 downto 0);

	type RGB is record
		r: std_logic_vector(2 downto 0);
		g: std_logic_vector(2 downto 0);
		b: std_logic_vector(1 downto 0);
	end record;
	
	type ColorList is array(0 to 9) of RGB;
	constant colors: ColorList := (
		("100", "010", "00"), -- brown
		("111", "000", "00"), -- red
		("111", "100", "00"), -- orange
		("111", "111", "00"), -- yellow
		("000", "110", "00"), -- green
		("000", "100", "11"), -- blue
		("011", "000", "11"), -- purple
		("100", "100", "10"), -- grey
		("111", "111", "11"), -- white
		("000", "000", "00")  -- black
	);
	
	type AnalogReadingType is array(natural range <>) of std_logic_vector(11 downto 0);
	signal analogReadings: AnalogReadingType(0 to 7) := (
		"000000011111",
		"000000111111",
		"000001111111",
		"000011111111",
		"000111111111",
		"001111111111",
		"011111111111",
		"101010101111"
	);
	
	-- Using an impure function here in order to access analogReadings. 
	-- Need to see if there is a preferred way to achieve this.
	impure function getReading(index: std_logic_vector(2 downto 0)) return integer is
		variable indexValue: integer := 0;
	begin
		indexValue := to_integer(unsigned(index));
		return to_integer(unsigned(analogReadings(indexValue)(11 downto 3)));     
	end function getReading;
		
	procedure setBlack is 
	begin
		redValue := "000";
		greenValue := "000";
		blueValue := "00";
	end procedure setBlack;
	
	procedure setColor(signal index: in std_logic_vector(2 downto 0)) is
		variable indexValue: integer := 0;
	begin
		indexValue := to_integer(unsigned(index));
		redValue := colors(indexValue).r;
		greenValue := colors(indexValue).g;
		blueValue := colors(indexValue).b;
	end procedure setColor;
	
begin

	theClock: clock25 port map(
		CLK_IN1 => clock32,
		CLK_OUT1 => clk25
	);
		
	myProcess: process(clk25, count, hCount, vCount)
	begin
		if rising_edge(clk25) then
		
			count <= count - 1;
		
			-- If we're at the end of the line...
			if (hCount = 799) then
			
				-- Go back to the beginning of the line.
				hCount <= (others => '0');
				
				-- And if we're also at the last line...
				if (vCount = 524) then
					-- Go back to the first line.
					vCount <= (others => '0'); 
				else
					-- Otherwise, go to the next line.
					vCount <= vCount + 1; 
				end if;
				
			else
				hCount <= hCount + 1;
			end if;
			
			-- Set the horizontal sync signal
			if (hCount >= 656) and (hCount < 752) then
				VGA_HSYNC <= '0';
			else
				VGA_HSYNC <= '1';
			end if;
			
			-- Set the vertical sync signal
			if (vCount = 490) or (vCount = 491) then
				VGA_VSYNC <= '0';
			else
				VGA_VSYNC <= '1';
			end if;
			
			-- Define the color to be displayed.
			if (vCount < 480) and (hCount < 640) then
			
				-- Set shading for visible pixels.
				if (vcount > getReading(hCount(8 downto 6))) then
					setColor(hCount(8 downto 6));
				else
					setBlack;
				end if;
				
			else
			
				-- Set pixels in the non-visible region to black.
				setBlack;
			end if;
		
		end if;
	end process;
		
	analogReadings(5) <= count(26 downto 15);
	
	VGA_RED <= redValue;
	VGA_GREEN <= greenValue;
	VGA_BLUE <= blueValue;
	
	Seg7_AN <= "1111";
	Seg7 <= "1111111";
	Seg7_DP <= '1';

end Behavioral;
