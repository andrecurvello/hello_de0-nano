-- hello_de0-nano
library ieee;
use ieee.std_logic_1164.all;

entity hello is
    generic(
        clock_freq_hz : integer;
        tick_freq_hz  : integer
    );
    port(
        clock : in  std_logic;
        led   : out std_logic_vector( 7 downto 0 )
    );
end hello;

architecture arch of hello is
    constant counter_max : integer := clock_freq_hz / ( tick_freq_hz * 2 ) ;
    signal   counter     : integer range 1 to counter_max := 1;
    signal   led_buffer  : std_logic := '0';
begin
    led(0) <= led_buffer;
    clk_div : process( clock )
    begin
        if rising_edge( clock ) then
            if( counter < counter_max ) then
                counter <= counter + 1;
            else
                counter <= 1;
                led_buffer <= not led_buffer;
            end if;
        end if;
    end process;
end architecture;
