
-- Compute the natural logaritm of an 8-bit unsigned integer using a look-up table approximation. See:
--
--     Alachiotis and Stamatakis (2009). "Efficient floating-point logarithm unit for FPGAs."
-- 
-- Designed for a Papilio Pro with LogicStart MegaWing.
--	
-- The result is unsigned Q4.8 fixed point. In this demo, the 4 integer bits are displayed
-- on the decimal points of the SSD, while the 8 decimal bits are displayed on the LED array.
--
-- Pushing the joystick left shows the Q3.8 log exponent term extracted from the LogExpLUT.
-- Pushing the joystick right shows the Q0.8 log mantissa term extracted from the LogLUT.
-- Pushing the joystick down shows the mantissa term on the LEDs, found by shifting the input to the most significant '1' bit.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Log is
	Port(
		clock: in std_logic;		
		Switches: in std_logic_vector(7 downto 0);
		JOY_DOWN_n: in std_logic;
		JOY_LEFT_n: in std_logic;
		JOY_RIGHT_n: in std_logic;
		
		LEDs: out std_logic_vector(7 downto 0);		
		Seg7_AN: out std_logic_vector(3 downto 0);
		Seg7: out std_logic_vector(6 downto 0);
		Seg7_DP: out std_logic
	);
end Log;

architecture Behavioral of Log is

	signal count: std_logic_vector(15 downto 0) := (others => '0');

	shared variable exponent: integer range 0 to 7 := 0;
	signal mantissa: std_logic_vector(7 downto 0) := (others => '0');
	signal logExponent: std_logic_vector(10 downto 0) := (others => '0');
	signal logMantissa: std_logic_vector(7 downto 0) := (others => '0');
	signal theSum: std_logic_vector(11 downto 0) := (others => '0');
	
	signal dpBits: std_logic_vector(3 downto 0) := (others => '0');
	
	component LogExpLUT
		PORT(
			clka: IN std_logic;
			addra: IN std_logic_vector(2 DOWNTO 0);
			douta: OUT std_logic_vector(10 DOWNTO 0)
		);
	end component;
	
	component LogLUT
		PORT(
			clka: IN std_logic;
			addra: IN std_logic_vector(7 DOWNTO 0);
			douta: OUT std_logic_vector(7 DOWNTO 0)
		);
	end component;
	
	component adder
		port(
			a: IN std_logic_vector(10 DOWNTO 0);
			b: IN std_logic_vector(10 DOWNTO 0);
			s: OUT std_logic_vector(11 DOWNTO 0)
		);
	end component;
	
begin

	-- Find the most significant '1' bit of the input.
	priorityEncoder: process(Switches)
	begin
		exponent := 0;
		for i in 0 to 7 loop
			if Switches(i) = '1' then
				exponent := i;
			end if;
		end loop;
	end process priorityEncoder;
	
	theLogExpLUT: LogExpLUT
		port map(
			clka => clock,
			addra => std_logic_vector(to_unsigned(exponent, 3)),
			douta => logExponent
		);	

	mantissa <=
		Switches when exponent = 7 else
		(Switches(6 downto 0) & "0") when exponent = 6 else
		(Switches(5 downto 0) & "00") when exponent = 5 else
		(Switches(4 downto 0) & "000") when exponent = 4 else
		(Switches(3 downto 0) & "0000") when exponent = 3 else
		(Switches(2 downto 0) & "00000") when exponent = 2 else
		(Switches(1 downto 0) & "000000") when exponent = 1 else
		(Switches(0 downto 0) & "0000000");
	
	theLogLUT: LogLUT
		port map(
			clka => clock,
			addra => ("0" & mantissa(6 downto 0)),
			douta => logMantissa
		);
	
	theAdder: adder
		port map(
			a => logExponent,           -- Q3.8
			b => ("000" & logMantissa), -- Q0.8
			s => theSum                 -- Q4.8
		);	
	
	LEDs <= 
		logExponent(7 downto 0) when JOY_LEFT_n = '0' else
		logMantissa when JOY_RIGHT_n = '0' else
		mantissa when JOY_DOWN_n = '0' else
		theSum(7 downto 0);

	dpBits <=
		not("0" & logExponent(10 downto 8)) when JOY_LEFT_n = '0' else
		"1111" when JOY_RIGHT_n = '0' else
		"1111" when JOY_DOWN_n = '0' else
		not(theSum(11 downto 8));
		
	seg7_clock: process(clock)
	begin
		if rising_edge(clock) then
			count <= count + 1;	
		end if;
	end process seg7_clock;

	-- Display 'E' on the LEDs to indicate an error for an input of zero.
	Seg7 <= 
		"0110000" when (Switches = "00000000") else
		(others => '1');

	seg7_process: process(count)
	begin
	
		CASE count(15 downto 14) IS
			WHEN "00" =>
				Seg7_AN <= "1110";
				Seg7_DP <= dpBits(0);
			WHEN "01" =>
				Seg7_AN <= "1101";
				Seg7_DP <= dpBits(1);
			WHEN "10" =>
				Seg7_AN <= "1011";
				Seg7_DP <= dpBits(2);
			WHEN "11" =>
				Seg7_AN <= "0111";
				Seg7_DP <= dpBits(3);
			WHEN OTHERS =>
				Seg7_AN <= "1111";
		END CASE;

	end process seg7_process;

end Behavioral;
