LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_Switches_LEDs IS
END tb_Switches_LEDs;
 
ARCHITECTURE behavior OF tb_Switches_LEDs IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Switches_LEDs
    PORT(
         switches: IN std_logic_vector(7 downto 0);
         LEDs: OUT std_logic_vector(7 downto 0);
         clock: IN std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal switches: std_logic_vector(7 downto 0) := (others => '0');
   signal clock: std_logic := '0';

 	--Outputs
   signal LEDs: std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period: time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Switches_LEDs PORT MAP (
          switches => switches,
          LEDs => LEDs,
          clock => clock
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
--      wait for 100 ns;	
--      wait for clock_period*10;

      -- insert stimulus here 
		switches <= "00000001";
		wait for 400 ns;
		switches <= "00000000";
      wait;
   end process;

END;
