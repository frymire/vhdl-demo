library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mimas_V2_VHDL_Tutorial is
	Port(
		DIP0: in STD_LOGIC;
      DIP1: in STD_LOGIC;
      LED0: out STD_LOGIC;
      LED1: out STD_LOGIC;
		
		-- Enable the control pins for the seven segment display
     SevenSegmentEnable0: out STD_LOGIC;
     SevenSegmentEnable1: out STD_LOGIC;
     SevenSegmentEnable2: out STD_LOGIC
	);
end Mimas_V2_VHDL_Tutorial;

architecture Behavioral of Mimas_V2_VHDL_Tutorial is

begin

	LED0 <= DIP1;
	LED1 <= DIP0;
	
	-- Set the 7 segment displays to off (they're active-low, so set the enables to 1).
	SevenSegmentEnable0 <= '1';
	SevenSegmentEnable1 <= '1';
	SevenSegmentEnable2 <= '1';
	
end Behavioral;

-- Special instructions to upload to FPGA.
-- Right click on "Generate Programming File" process, select "Process Properties"
-- Enable "Create Binary Configuration File"
-- Upload the "bin" file, not the "bit" file to the FPGA.
