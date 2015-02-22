-- Universal Asynchronous Receiver
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic(
        clock_freq_hz : integer;
        baud_hz       : integer
    );
    port(
        clock  : in  std_logic;
        busy   : out std_logic;
        enable : in  std_logic;
        wire   : in  std_logic;
        data   : out std_logic_vector(7 downto 0)
    );
end uart_rx;

architecture uart_rx_arch of uart_rx is
begin
end architecture uart_rx_arch;
