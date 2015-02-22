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
    -- TODO(aray): XXX REMOVEME BARF HACK
    signal   busy         : std_logic;
    signal   enable       : std_logic := '0';
    signal   wire         : std_logic;
    signal   data         : std_logic_vector(7 downto 0);
	 
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
    component uart_tx
        generic(
            clock_freq_hz : integer;
            baud_hz       : integer
        );
        port( 
            clock  : in  std_logic;
            busy   : out std_logic;
            enable : in  std_logic;
            wire   : out std_logic;
            data   : in  std_logic_vector( 7 downto 0) := "00000000"
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
    uart_tx_u0: uart_tx
        generic map (
            clock_freq_hz => 50000000,
            baud_hz  =>          9600
        )
        port map (
            clock  => CLOCK_50,
            busy   => busy,
            enable => enable,
            wire   => wire,
            data   => data
        )
    ;
end architecture;
