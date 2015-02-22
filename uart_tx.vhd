-- Universal Asynchronous Transmitter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic(
        clock_freq_hz : integer;
        baud_hz       : integer
    );
    port(
        clock  : in  std_logic;
        busy   : out std_logic;
        enable : in  std_logic;
        wire   : out std_logic;
        data   : in  std_logic_vector(7 downto 0)
    );
end uart_tx;

architecture uart_tx_arch of uart_tx is
begin
end architecture uart_tx_arch;
