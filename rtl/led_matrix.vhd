--
-- Matthew Hagerty
-- Jan 2022
-- Public Domain
--
-- If you are in University, your prof will know if you copy this.
-- Use it to learn, otherwise, what are you doing in Uni anyway?
--
-- 5x7 dot matrix display row selector with hard-coded pattern.
-- Simulation and synthesis proven.
--
-- Current limiting resistors are recommended for direct
-- wiring to FPGA I/O.  Typically 100-ohms on the row connections
-- will suffice.
--
-- Common Cathode
--
--       C1   C2   C3   C4   C5
--        |    |    |    |    |
--      +-+  +-+  +-+  +-+  +-+
--     ~V | ~V | ~V | ~V | ~V |
-- R1 --+-|--+-|--+-|--+-|--+ |
--        |    |    |    |    |
--      +-+  +-+  +-+  +-+  +-+
--     ~V | ~V | ~V | ~V | ~V |
-- R2 --+-|--+-|--+-|--+-|--+ |
--        .    .    .    .    .
--        .    .    .    .    .
--        .    .    .    .    .
--      +-+  +-+  +-+  +-+  +-+
--     ~V | ~V | ~V | ~V | ~V |
-- R7 --+-|--+-|--+-|--+-|--+ |
--
--
-- Common Anode
--
--       C1   C2   C3   C4   C5
--        |    |    |    |    |
--      +-+  +-+  +-+  +-+  +-+
--     ~^ | ~^ | ~^ | ~^ | ~^ |
-- R1 --+-|--+-|--+-|--+-|--+ |
--        |    |    |    |    |
--      +-+  +-+  +-+  +-+  +-+
--     ~^ | ~^ | ~^ | ~^ | ~^ |
-- R2 --+-|--+-|--+-|--+-|--+ |
--        .    .    .    .    .
--        .    .    .    .    .
--        .    .    .    .    .
--      +-+  +-+  +-+  +-+  +-+
--     ~^ | ~^ | ~^ | ~^ | ~^ |
-- R7 --+-|--+-|--+-|--+-|--+ |
--
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


entity led_matrix is
generic
   ( G_ENABLE_POLARITY : std_logic := '0' -- '1' common cathode
);                                        -- '0' common anode
port
   ( clk_i           : in     std_logic
   ; next_row_en_ci  : in     std_logic
   ; row_enables_o   : out    std_logic_vector(1 to 7)
   ; row_pattern_o   : out    std_logic_vector(1 to 5)
);
end led_matrix;


architecture rtl of led_matrix is

   -- Hard-coded pattern.  Should be replaced with a read/write
   -- memory so the pattern can be modified.
   constant PATTERN_ROW1 : std_logic_vector(1 to 5) := "00100";
   constant PATTERN_ROW2 : std_logic_vector(1 to 5) := "01110";
   constant PATTERN_ROW3 : std_logic_vector(1 to 5) := "10101";
   constant PATTERN_ROW4 : std_logic_vector(1 to 5) := "10101";
   constant PATTERN_ROW5 : std_logic_vector(1 to 5) := "11111";
   constant PATTERN_ROW6 : std_logic_vector(1 to 5) := "01010";
   constant PATTERN_ROW7 : std_logic_vector(1 to 5) := "11011";

   -- Pattern register for the current row.
   signal pattern_r   : std_logic_vector(1 to 5) := (others => '0');
   signal pattern_x   : std_logic_vector(1 to 5);

   -- Current row counter 1..7 are used, 0 is ignored.
   signal rowcnt_r : unsigned(2 downto 0) := (others => '0');
   signal rowcnt_x : unsigned(2 downto 0);

   -- Row enable register.
   signal row_en_r : std_logic_vector(1 to 7) := (others => G_ENABLE_POLARITY);
   signal row_en_x : std_logic_vector(1 to 7);

   -- Row enables.
   signal row1_en_s : std_logic;
   signal row2_en_s : std_logic;
   signal row3_en_s : std_logic;
   signal row4_en_s : std_logic;
   signal row5_en_s : std_logic;
   signal row6_en_s : std_logic;
   signal row7_en_s : std_logic;

begin

   -- Registered outputs.
   row_enables_o <= row_en_r;
   row_pattern_o <= pattern_r;

   row_selection : process
   ( rowcnt_r, pattern_r
   , row1_en_s, row2_en_s, row3_en_s, row4_en_s, row5_en_s, row6_en_s, row7_en_s
   )
   begin

      -- Default all rows disabled.
      row1_en_s <= G_ENABLE_POLARITY;
      row2_en_s <= G_ENABLE_POLARITY;
      row3_en_s <= G_ENABLE_POLARITY;
      row4_en_s <= G_ENABLE_POLARITY;
      row5_en_s <= G_ENABLE_POLARITY;
      row6_en_s <= G_ENABLE_POLARITY;
      row7_en_s <= G_ENABLE_POLARITY;

      case ( rowcnt_r ) is

         when "001" =>  pattern_x <= PATTERN_ROW1;
                        row1_en_s <= not G_ENABLE_POLARITY;
         when "010" =>  pattern_x <= PATTERN_ROW2;
                        row2_en_s <= not G_ENABLE_POLARITY;
         when "011" =>  pattern_x <= PATTERN_ROW3;
                        row3_en_s <= not G_ENABLE_POLARITY;
         when "100" =>  pattern_x <= PATTERN_ROW4;
                        row4_en_s <= not G_ENABLE_POLARITY;
         when "101" =>  pattern_x <= PATTERN_ROW5;
                        row5_en_s <= not G_ENABLE_POLARITY;
         when "110" =>  pattern_x <= PATTERN_ROW6;
                        row6_en_s <= not G_ENABLE_POLARITY;
         when "111" =>  pattern_x <= PATTERN_ROW7;
                        row7_en_s <= not G_ENABLE_POLARITY;
         when others => pattern_x <= pattern_r;

      end case;
   end process;

   row_en_x <= row1_en_s & row2_en_s & row3_en_s &
               row4_en_s & row5_en_s & row6_en_s &
               row7_en_s;

   rowcnt_x <= rowcnt_r + 1;

   row_rt : process ( clk_i )
   begin
      if rising_edge( clk_i ) then
         if next_row_en_ci = '1' then
            if G_ENABLE_POLARITY = '1' then
               pattern_r <= pattern_x;
            else
               pattern_r <= not pattern_x;
            end if;
            row_en_r  <= row_en_x;
            rowcnt_r  <= rowcnt_x;
         end if;
      end if;
   end process;

end rtl;
