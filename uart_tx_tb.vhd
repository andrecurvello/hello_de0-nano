-- uart_tx testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
end entity uart_tx_tb;

architecture uart_tx_tb_arch of uart_tx_tb is
    constant clock_period : time := 20 ns;
    signal   clock        : std_logic := '0';
    signal   busy         : std_logic := '0';
    signal   enable       : std_logic := '0';
    signal   wire         : std_logic := '0';
    signal   data         : std_logic_vector(7 downto 0);

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

begin -- architecture uart_tx_tb_arch
    uart_tx_u0: uart_tx
        generic map (
            clock_freq_hz => 50000000,
            baud_hz  =>       5000000
        )
        port map (
            clock  => clock,
            busy   => busy,
            enable => enable,
            wire   => wire,
            data   => data
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
        data <= "01001101";
        enable <= '1';
		  wait for clock_period;
		  data <= "00000000";
		  enable <= '0';
		  wait;
    end process init;

end architecture uart_tx_tb_arch;
