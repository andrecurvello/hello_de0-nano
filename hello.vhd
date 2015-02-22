-- hello_de0-nano
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    constant clk_counter_max : integer := clock_freq_hz / ( tick_freq_hz * 2 );
    constant led_counter_max : integer := 255; -- 2^8 for 8 LEDs
    signal   clk_counter     : integer range 1 to clk_counter_max := 1;
    signal   led_counter     : integer range 0 to led_counter_max := 0;
    signal   led_tick        : std_logic := '0';
begin
    led <= std_logic_vector( to_unsigned( led_counter , led'length ) );

    clk_div : process( clock )
    begin
        if rising_edge( clock ) then
            if( clk_counter < clk_counter_max ) then
                clk_counter <= clk_counter + 1;
                led_tick <= '0';
            else
                clk_counter <= 1;
                led_tick <= '1';
            end if;
        end if;
    end process clk_div;

    tick : process( led_tick )
    begin
        if rising_edge( led_tick ) then
            if( led_counter = led_counter_max ) then
                led_counter <= 0;
            else
                led_counter <= led_counter + 1;
            end if;
        end if;
    end process tick;
end architecture;
