-- uart_rx testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end entity uart_rx_tb;

architecture uart_rx_tb_arch of uart_rx_tb is
    constant clock_period  : time := 20 ns;
    constant clock_freq_hz : integer := 50000000;
    constant baud_hz       : integer := 5000000;
    signal   clock         : std_logic := '0';
    signal   tx_busy       : std_logic := '0';
    signal   tx_enable     : std_logic := '0';
    signal   tx_reset      : std_logic := '0';
    signal   tx_data       : std_logic_vector(7 downto 0);
    signal   wire          : std_logic := '0';
    signal   rx_busy       : std_logic := '0';
    signal   rx_reset      : std_logic := '0';
    signal   rx_valid      : std_logic := '0';
    signal   rx_data       : std_logic_vector(7 downto 0);

    component uart_tx
        generic(
            clock_freq_hz : integer;
            baud_hz       : integer
        );
        port( 
            clock  : in  std_logic;
            busy   : out std_logic;
            enable : in  std_logic;
            reset  : in  std_logic;
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

begin -- architecture uart_rx_tb_arch
    uart_tx_u0: uart_tx
        generic map (
            clock_freq_hz => clock_freq_hz,
            baud_hz  =>      baud_hz
        )
        port map (
            clock  => clock,
            busy   => tx_busy,
            enable => tx_enable,
            reset  => tx_reset,
            wire   => wire,
            data   => tx_data
        )
    ;

    uart_rx_u0: uart_rx
        generic map (
            clock_freq_hz => clock_freq_hz,
            baud_hz  =>      baud_hz
        )
        port map (
            clock  => clock,
            reset  => rx_reset,
            wire   => wire,
            busy   => rx_busy,
            valid  => rx_valid,
            data   => rx_data
        )
    ;

    clk_gen : process
    begin
        loop
            clock <= '1';
            wait for clock_period / 2;
            clock <= '0';
            wait for clock_period / 2;
        end loop;
    end process clk_gen;

    init : process
    begin
        wait for clock_period;
        tx_data <= "01001101";
        tx_enable <= '1';
        wait for clock_period;
        tx_data <= "00000000";
        tx_enable <= '0';
        wait for clock_period * 10;
        tx_reset <= '1';
        rx_reset <= '1';
        tx_data <= "00110011";
        tx_enable <= '1';
        wait for clock_period;
        tx_reset <= '0';
        rx_reset <= '0';
        wait for clock_period;
        tx_data <= "00000000";
        tx_enable <= '0';
        wait; -- leave this one last to run this process only once
    end process init;

end architecture uart_rx_tb_arch;
