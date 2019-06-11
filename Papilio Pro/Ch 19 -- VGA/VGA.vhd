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
	
	signal hCount: std_logic_vector(9 downto 0) := (others => '0');
	signal vCount: std_logic_vector(9 downto 0) := (others => '0');
	
begin

	theClock: clock25 port map(
		CLK_IN1 => clock32,
		CLK_OUT1 => clk25
	);
	
	myProcess: process(clk25, hCount, vCount)
		begin
			if rising_edge(clk25) then
			
				-- If we're at the end of the line...
				if (hCount = 799) then
				
					-- Go back to the beginning of the line.
					hCount <= (others => '0');
					
					-- If we're at the last line...
					if (vCount = 524) then
						vCount <= (others => '0');
					else
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
				
				-- Define the color to be displayed
				if (vCount < 480) then
					case hCount(7 downto 6) is
						when "00" =>
							VGA_RED <= "111";
							VGA_GREEN <= "000";
							VGA_BLUE <= "00";					
						when "01" =>
							VGA_RED <= "000";
							VGA_GREEN <= "111";
							VGA_BLUE <= "00";					
						when "10" =>
							VGA_RED <= "000";
							VGA_GREEN <= "000";
							VGA_BLUE <= "11";					
						when "11" =>
							VGA_RED <= "111";
							VGA_GREEN <= "000";
							VGA_BLUE <= "11";					
						when others =>
							VGA_RED <= "000";
							VGA_GREEN <= "000";
							VGA_BLUE <= "00";										
					end case;
				
				end if;
			
			end if;
		end process;
	
	Seg7_AN <= "1110";
	Seg7 <= "1001111";
	Seg7_DP <= '1';

end Behavioral;
