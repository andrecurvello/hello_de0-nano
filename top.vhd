-- hello_de0-nano - top entity, contains hello
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port(
        CLOCK_50 : in  std_logic;
        LED      : out std_logic_vector( 7 downto 0 )
    );
end top;

architecture arch of top is
    component hello
        generic(
            clock_freq_hz : integer;
            tick_freq_hz  : integer
        );
        port( 
            clock : in  std_logic;
            led   : out std_logic_vector( 7 downto 0 )
        );
    end component;
begin
    hello_u0: hello
        generic map (
            clock_freq_hz => 50000000,
            tick_freq_hz => 10
        )
        port map (
            clock => CLOCK_50,
            led   => LED
        )
    ;
end architecture;
