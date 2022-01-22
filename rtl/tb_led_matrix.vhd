--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:50:05 01/22/2022
-- Design Name:   
-- Module Name:   /home/ise/FPGA/led5x7matrix/rtl/tb_led_matrix.vhd
-- Project Name:  ISE_LED5X7MATRIX
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: led_matrix
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_led_matrix IS
END tb_led_matrix;
 
ARCHITECTURE behavior OF tb_led_matrix IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT led_matrix
	 GENERIC( G_ENABLE_POLARITY : std_logic := '1' -- '1' common cathode
    );                                            -- '0' common anode
    PORT(
         clk_i : IN  std_logic;
         next_row_en_ci : IN  std_logic;
         row_enables_o : OUT  std_logic_vector(1 to 7);
         row_pattern_o : OUT  std_logic_vector(1 to 5)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal next_row_en_ci : std_logic := '0';

 	--Outputs
   signal row_enables_o : std_logic_vector(1 to 7);
   signal row_pattern_o : std_logic_vector(1 to 5);

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: led_matrix 
	GENERIC MAP ( G_ENABLE_POLARITY => '0' )
	PORT MAP (
          clk_i => clk_i,
          next_row_en_ci => next_row_en_ci,
          row_enables_o => row_enables_o,
          row_pattern_o => row_pattern_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_i_period*10;

      -- insert stimulus here 
		next_row_en_ci <= '1';

      wait;
   end process;

END;
