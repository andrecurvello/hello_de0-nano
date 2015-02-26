-- hello testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hello_tb is
end entity hello_tb;

architecture hello_tb_arch of hello_tb is
    constant clock_period : time := 20 ns;
    signal   clock        : std_logic;
    signal   led          : std_logic_vector(7 downto 0);
    signal   tick         : std_logic;

    component hello
        generic(
            clock_freq_hz : integer;
            tick_freq_hz  : integer
        );
        port(
            clock : in  std_logic;
            led   : out std_logic_vector( 7 downto 0 );
            tick  : out std_logic
        );
    end component hello;

begin -- architecture hello_tb_arch
    hello_u0: hello
        generic map (
            clock_freq_hz => 50000000,
            tick_freq_hz  =>  5000000
        )
        port map (
            clock => clock,
            led   => led,
            tick  => tick
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
        wait;
    end process init;

end architecture hello_tb_arch;
