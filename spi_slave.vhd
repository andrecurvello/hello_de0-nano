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
  signal   data_tx_reg     : std_logic_vector(8 downto 0) := "000000000";
  signal   data_rx_reg     : std_logic_vector(7 downto 0) := "00000000";
  signal   sclk_reg        : std_logic := cpol;
  signal   miso_reg        : std_logic := '0';
begin  -- architecture spi_slave_arch of spi_slave
  done    <= done_reg;
  data_rx <= data_rx_reg;
  miso    <= data_tx_reg(7);

  -- TODO(aray): oh crap clean up the nesting (See also TODO:Learn VHDL)
  spi_div : process(ss_l, sclk)
  begin
    done <= '0';
    if falling_edge(ss_l) then
      data_tx_reg <= data_tx & '1';  -- latch in data to transmit
    elsif rising_edge(ss_l) then
      if (data_tx_reg = "100000000") then  -- successfully finished
        done <= '1';
      end if;
    elsif rising_edge(sclk) then
      if ((cpol xor cpha) = '1') then -- switch time!
        data_tx_reg <= data_tx_reg(7 downto 0) & '0';  -- shift out
      else -- sample time!
        data_rx_reg <= data_rx_reg(6 downto 0) & mosi;  -- shift in
      end if;
    elsif falling_edge(sclk) then
      if ((cpol xor cpha) = '0') then -- switch time!
        data_tx_reg <= data_tx_reg(7 downto 0) & '0';  -- shift out
      else -- sample time!
        data_rx_reg <= data_rx_reg(6 downto 0) & mosi;  -- shift in
      end if;
    end if;
  end process spi_div;
end architecture spi_slave_arch;
