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
    signal  tx_busy   : std_logic;
    signal  tx_enable : std_logic;
    signal  tx_wire   : std_logic;
    signal  tx_data   : std_logic_vector(7 downto 0);
    signal  rx_reset  : std_logic;
    signal  rx_wire   : std_logic;
    signal  rx_busy   : std_logic;
    signal  rx_valid  : std_logic;
    signal  rx_data   : std_logic_vector(7 downto 0);

	 
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
            data   : in  std_logic_vector( 7 downto 0)
        );
    end component;
    component uart_rx
        generic(
            clock_freq_hz : integer;
            baud_hz       : integer
        );
        port(
            clock  : in  std_logic;
            reset  : in  std_logic;
            wire   : in  std_logic;
            busy   : out std_logic;
            valid  : out std_logic;
            data   : out std_logic_vector(7 downto 0)
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
            busy   => tx_busy,
            enable => tx_enable,
            wire   => tx_wire,
            data   => tx_data
        )
    ;
    uart_rx_u0: uart_rx
        generic map (
            clock_freq_hz => 50000000,
            baud_hz  =>      25000000
        )
        port map (
            clock  => CLOCK_50,
            reset  => rx_reset,
            wire   => rx_wire,
            busy   => rx_busy,
            valid  => rx_valid,
            data   => rx_data
        )
    ;
end architecture;
