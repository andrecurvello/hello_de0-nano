-- Bad ACKtor - pseudo I2C device that only ACKs
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bad_acktor is
  port(
    -- External (I2C) interface
    sda : inout std_logic;  -- Serial Data Line
    scl : in    std_logic   -- Serial Clock Line
  );
end bad_acktor;

architecture bad_acktor_arch of bad_acktor is
  signal   clk_counter     : integer range 1 to 9 := 1;
begin  -- architecture bad_acktor_arch of bad_acktor

  scl_process : process(scl)
  begin
    if falling_edge(scl) then
      if (clk_counter = 9) then
        clk_counter <= 1;
      else
        clk_counter <= clk_counter + 1;
        if (clk_counter = 8) then
          sda <= '0';
        else
          sda <= 'Z';
        end if;
      end if;
    end if;
  end process scl_process;
end architecture bad_acktor_arch;
