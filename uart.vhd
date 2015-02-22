-- Universal Asynchronous Receiver / Transmitter
-- TODO(aray): they can probably share clock dividers
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic(
        clock_freq_hz : integer;
        baud_hz       : integer
    );
    port(
        clock     : in  std_logic;
        rx_busy   : out std_logic;
        rx_enable : in  std_logic;
        rx_wire   : in  std_logic;
        rx_data   : out std_logic_vector( 7 downto 0);
        tx_busy   : out std_logic;
        tx_enable : in  std_logic;
        tx_wire   : out std_logic;
        tx_data   : in  std_logic_vector( 7 downto 0)
    );
end uart;

architecture uart_arch of uart is
    component uart_rx
        generic(
            clock_freq_hz : integer;
            baud_hz       : integer
        );
        port( 
            clock  : in  std_logic;
            busy   : out std_logic;
            enable : in  std_logic;
            wire   : in  std_logic;
            data   : out std_logic_vector( 7 downto 0)
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
begin
    uart_rx_u0: uart_rx
        generic map (
            clock_freq_hz => clock_freq_hz,
            baud_hz       => baud_hz
        )
        port map (
            clock  => clock,
            busy   => rx_busy,
            enable => rx_enable,
            wire   => rx_wire,
            data   => rx_data
        )
    ;
    uart_tx_u0: uart_tx
        generic map (
            clock_freq_hz => clock_freq_hz,
            baud_hz       => baud_hz
        )
        port map (
            clock  => clock,
            busy   => tx_busy,
            enable => tx_enable,
            wire   => tx_wire,
            data   => tx_data
        )
    ;
end architecture uart_arch;
