-- Serial Peripheral Interface Bus - Slave
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
  generic(
    cpol             : std_logic;  -- Clock Polarity
    cpha             : std_logic   -- Clock Phase
  );
  port(
    -- Internal (FPGA) interface
    fpga_clock  : in  std_logic;  -- input clock
    done        : out std_logic;  -- indicates SPI transaction complete
    data_tx     : in  std_logic_vector(7 downto 0);  -- data to transmit
    data_rx     : out std_logic_vector(7 downto 0);  -- data received

    -- External (SPI) interface
    sclk        : in  std_logic;  -- Serial Clock
    mosi        : in  std_logic;  -- Master Output, Slave Input
    miso        : out std_logic;  -- Master Input, Slave Output
    ss_l        : in  std_logic   -- Slave Select (active low)
  );
end spi_slave;

architecture spi_slave_arch of spi_slave is
  signal   done_reg        : std_logic := '0';
  signal   data_tx_reg     : std_logic_vector(7 downto 0) := "00000000";
  signal   data_rx_reg     : std_logic_vector(8 downto 0) := "000000000";
  signal   miso_reg        : std_logic := '0';
begin  -- architecture spi_slave_arch of spi_slave
  done    <= done_reg;
  miso    <= data_tx_reg(7);
  data_rx <= data_rx_reg(7 downto 0);

  -- TODO(aray): oh crap clean up the nesting (See also TODO:Learn VHDL)
  spi_div : process(ss_l, clk_reg)
  begin
    done_reg <= '0';
    if (ss_l = '1') then
      if (data_tx_reg = "100000000") then  -- successfully finished
        done_reg <= '1';
      end if;
      data_tx_reg <= "000000000";
    else
      if (data_tx_reg = "000000000") then  -- start time!
        data_tx_reg <= data_tx & '1';                   -- latch in
      elsif falling_edge(clk_reg) then     -- switch time!
        data_tx_reg <= data_tx_reg(7 downto 0) & '0';   -- shift out
      elsif rising_edge(clk_reg) then      -- sample time!
        data_rx_reg <= data_rx_reg(6 downto 0) & mosi;  -- shift in
      end if;
    end if;
  end process spi_div;

  clk_div : process(fpga_clock)
  begin
    if rising_edge(fpga_clock) then
      done_reg <= '0';
      if (ss_l = '0') then
        boo;
      end if;
    end if;
  end process clk_div;
end architecture spi_slave_arch;
