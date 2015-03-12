-- spi_slave testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave_tb is
end entity spi_slave_tb;

architecture spi_slave_tb_arch of spi_slave_tb is
    constant clock_period : time := 20 ns;
    signal   clock        : std_logic := '0';
    signal   enable       : std_logic := '0';
    signal   reset        : std_logic := '0';
    signal   busy         : std_logic := '0';
    signal   master_done  : std_logic := '0';
    signal   master_tx    : std_logic_vector(7 downto 0) := "00000000";
    signal   master_rx    : std_logic_vector(7 downto 0) := "00000000";
    signal   slave_done   : std_logic := '0';
    signal   slave_tx     : std_logic_vector(7 downto 0) := "00000000";
    signal   slave_rx     : std_logic_vector(7 downto 0) := "00000000";
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

    component spi_slave
      generic(
        cpol             : std_logic;
        cpha             : std_logic
      );
      port(
        done        : out std_logic;
        data_tx     : in  std_logic_vector(7 downto 0);
        data_rx     : out std_logic_vector(7 downto 0);
        sclk        : in  std_logic;
        mosi        : in  std_logic;
        miso        : out std_logic;
        ss_l        : in  std_logic
      );
    end component;
begin -- architecture spi_slave_tb_arch
    spi_master_u0: spi_master
        generic map (
            fpga_clk_freq_hz => 50000000,
            sclk_freq_hz =>     25000000,
            cpol => '0',
            cpha => '0'
        )
        port map (
            fpga_clock => clock,
            enable     => enable,
            reset      => reset,
            busy       => busy,
            done       => master_done,
            data_tx    => master_tx,
            data_rx    => master_rx,
            sclk       => sclk,
            mosi       => mosi,
            miso       => miso,
            ss_l       => ss_l
        )
    ;

    spi_slave_u0: spi_slave
        generic map (
            cpol => '0',
            cpha => '0'
        )
        port map (
            done       => slave_done,
            data_tx    => slave_tx,
            data_rx    => slave_rx,
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
        master_tx <= "10101101";
        slave_tx <= "01010101";
        enable <= '1';
        wait for clock_period;
        master_tx <= "00000000";
        enable <= '0';
        wait for clock_period * 15;
        master_tx <= "01101000";
        slave_tx <= "11011100";
        enable <= '1';
        wait for clock_period;
        master_tx <= "00000000";
        enable <= '0';
        wait; -- leave this one last to run this process only once
    end process init;
end architecture spi_slave_tb_arch;
