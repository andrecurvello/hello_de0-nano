-- hello_de0-nano - top entity, contains hello
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port(
        CLOCK_50 : in  std_logic;
        LED      : out std_logic_vector( 7 downto 0 );
        GPIO_0   : inout std_logic_vector( 33 downto 0 ) := (others => 'Z')
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
    signal  spi_enable  : std_logic;
    signal  spi_reset   : std_logic;
    signal  spi_busy    : std_logic;
    signal  spi_done    : std_logic;
    signal  spi_data_tx : std_logic_vector(7 downto 0);
    signal  spi_data_rx : std_logic_vector(7 downto 0);
    signal  spi_sclk    : std_logic;
    signal  spi_mosi    : std_logic;
    signal  spi_miso    : std_logic;
    signal  spi_ss_l    : std_logic;

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
begin
    GPIO_0(0) <= tx_wire;
    GPIO_0(1) <= rx_wire;
    LED <= tx_data;

    hello_u0: hello
        generic map (
            clock_freq_hz => 50000000,
            tick_freq_hz => 10
        )
        port map (
            clock => CLOCK_50,
            led   => tx_data,
            tick  => tx_enable
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
            baud_hz  =>          9600
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
    spi_master_u0: spi_master
        generic map (
            fpga_clk_freq_hz => 50000000,
            sclk_freq_hz => 1000000,
            cpol => '0',
            cpha => '0'
        )
        port map (
            fpga_clock => CLOCK_50,
            enable     => spi_enable,
            reset      => spi_reset,
            busy       => spi_busy,
            done       => spi_done,
            data_tx    => spi_data_tx,
            data_rx    => spi_data_rx,
            sclk       => spi_sclk,
            mosi       => spi_mosi,
            miso       => spi_miso,
            ss_l       => spi_ss_l
        )
    ;
end architecture;
