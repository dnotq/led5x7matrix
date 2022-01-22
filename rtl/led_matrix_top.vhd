--
-- Matthew Hagerty
-- Jan 2022
-- Public Domain
--
-- If you are in University, your prof will know if you copy this.
-- Use it to learn, otherwise, what are you doing in Uni anyway?
--
-- LED 5x7 Dot Matrix Top
-- Digilent Spartan-3E Starter Board
-- Simulation and synthesis proven.
--
-- Naming Convention:
--   _i   input, from register
--   _ci  input, from combinatorial logic
--   _o   output, registered
--   _co  output, combinatorial
--   _r   register
--   _x   next state signal/wire for registers
--   _s   signal/wire, combinatorial
--   _sb  combinatorial strobe
--   _n_  active-low signal

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_matrix_top is
port
   ( clk_50m0_i_net     : in     std_logic
   ; row_enables_o_net  : out    std_logic_vector(1 to 7)
   ; row_pattern_o_net  : out    std_logic_vector(1 to 5)
);
end led_matrix_top;

architecture rtl of led_matrix_top is

   signal clk_50m0_s    : std_logic;

   -- Row update  Counter
   -- frequency   size
   -- -------------------
   --  ~ 1ms      16-bit
   --  ~ 50ms     20-bit
   --  ~ 250ms    24-bit
   --
   -- Clock divider.  Ordering the bits 0..n allows bit-0 to always be the
   -- MSbit without having to change the HDL.
   signal next_row_en_s : std_logic;
   signal clkdiv_r      : unsigned(0 to 15) := (others => '0');
   signal clkdiv_x      : unsigned(0 to 15);
   signal clk_last_r    : std_logic := '0';

   -- LED matrix signals.  These are not necessary in this design, but would
   -- allow access to the signals prior to going out to nets.
   signal row_enables_s : std_logic_vector(1 to 7);
   signal row_pattern_s : std_logic_vector(1 to 5);

begin

   -- In a larger design the clock would most likely come from a DCM, or
   -- at least a clock buffer.
   clk_50m0_s <= clk_50m0_i_net;

   -- Always count.
   clkdiv_x <= clkdiv_r + 1;

   clk_div : process ( clk_50m0_s )
   begin
      if rising_edge ( clk_50m0_s ) then
         clkdiv_r    <= clkdiv_x;
         clk_last_r  <= clkdiv_r(0);
      end if;
   end process;

   -- Rising edge detect the MSbit of the counter once per cycle.
   next_row_en_s <= clkdiv_r(0) and (not clk_last_r);


   inst_row_select : entity work.led_matrix
   generic map
   ( G_ENABLE_POLARITY => '0' -- '1' common cathode
   )                          -- '0' common anode
   port map
   ( clk_i           => clk_50m0_s
   , next_row_en_ci  => next_row_en_s
   , row_enables_o   => row_enables_s
   , row_pattern_o   => row_pattern_s
   );

   -- Outputs.
   row_enables_o_net <= row_enables_s;
   row_pattern_o_net <= row_pattern_s;

end rtl;
