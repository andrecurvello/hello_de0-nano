-- Hello_DE0-Nano - top entity, contains hello
library IEEE;
use IEEE.std_logic_1164.ALL;

entity top is
    Port(
        CLOCK_50 : IN  std_logic;
        LED      : OUT std_logic_vector( 7 downto 0 )
    );
end top;

architecture Arch of top is
    component hello
        generic(
            clock_freq_hz : integer;
            tick_freq_hz  : integer
        );
        Port( 
            CLOCK_50 : IN  std_logic;
            LED      : OUT std_logic_vector( 7 downto 0 )
        );
    end component;
begin
    hello_U0: hello
        generic map (
            clock_freq_hz => 50000000,
            tick_freq_hz => 10
        )
        port map (
            CLOCK_50 => CLOCK_50,
            LED => LED
        )
    ;
end architecture;
