-- spi_master testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master_tb is
end entity spi_master_tb;

architecture spi_master_tb_arch of spi_master_tb is
    constant clock_period : time := 20 ns;
    signal   clock   : std_logic := '0';
    signal   enable       : std_logic := '0';
    signal   reset        : std_logic := '0';
    signal   busy         : std_logic := '0';
    signal   done         : std_logic := '0';
    signal   data_tx      : std_logic_vector(7 downto 0) := "00000000";
    signal   data_rx      : std_logic_vector(7 downto 0) := "00000000";
    signal   sclk         : std_logic := '0';
    signal   mosi         : std_logic := '0';
    signal   miso         : std_logic := '0';
    signal   ss_l         : std_logic := '0';

    component spi_master
        generic(
            fpga_clk_freq_hz : integer;
            sclk_freq_hz     : integer;
            cpol             : std_logic;
            cpha             : std_logic
        );
        port(
            fpga_clock  : in  std_logic;
            enable      : in  std_logic;
            reset       : in  std_logic;
            busy        : out std_logic;
            done        : out std_logic;
            data_tx     : in  std_logic_vector(7 downto 0);
            data_rx     : out std_logic_vector(7 downto 0);
            sclk        : out std_logic;
            mosi        : out std_logic;
            miso        : in  std_logic;
            ss_l        : out std_logic
        );
    end component;
begin -- architecture spi_master_tb_arch
    spi_master_u0: spi_master
        generic map (
            fpga_clk_freq_hz => 50000000,
            sclk_freq_hz => 25000000,
            cpol => '0',
            cpha => '0'
        )
        port map (
            fpga_clock => clock,
            enable     => enable,
            reset      => reset,
            busy       => busy,
            done       => done,
            data_tx    => data_tx,
            data_rx    => data_rx,
            sclk       => sclk,
            mosi       => mosi,
            miso       => miso,
            ss_l       => ss_l
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
        wait for clock_period / 2;
        data_tx <= "10101101";
        enable <= '1';
        wait for clock_period;
        data_tx <= "00000000";
        enable <= '0';
        wait for clock_period * 15;
        data_tx <= "01101000";
        enable <= '1';
        wait for clock_period;
        data_tx <= "00000000";
        enable <= '0';
        wait; -- leave this one last to run this process only once
    end process init;
end architecture spi_master_tb_arch;
