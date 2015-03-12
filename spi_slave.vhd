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
  signal   data_rx_reg     : std_logic_vector(8 downto 0) := "000000000";
  signal   miso_reg        : std_logic := '0';
  signal   clk_reg         : std_logic := '0';
begin  -- architecture spi_slave_arch of spi_slave
  done    <= data_rx_reg(8);
  data_rx <= data_rx_reg(7 downto 0);
  miso    <= data_tx_reg(8);
  clk_reg <= (cpol xor cpha xor sclk);

  -- TODO(aray): oh crap clean up the nesting (See also TODO:Learn VHDL)
  p : process(ss_l, clk_reg)
  begin
    if (ss_l = '1') then  -- reset time!
      data_rx_reg <= "000000000";
      data_tx_reg <= "000000000";
    else
      if (data_rx_reg = "000000000") then  -- start time!
        data_tx_reg <= data_tx & '1';
        data_rx_reg <= "000000001";
      else -- TODO: bring up RTL viewer, make sure these statements are sensible
        if rising_edge(clk_reg) then  -- sample time!
          if (data_rx_reg(8) = '1') then  -- continue to next byte
            data_rx_reg <= "00000001" & mosi;
          else
            data_rx_reg <= data_rx_reg(7 downto 0) & mosi;  -- shift in
          end if;
        elsif falling_edge(clk_reg) then  -- switch time!
          if (data_tx_reg = "100000000") then
            data_tx_reg <= data_tx & '1';  -- continue to next byte
          else
            data_tx_reg <= data_tx_reg(7 downto 0) & '0';   -- shift out
          end if;
        end if;
      end if;
    end if;
  end process p;
end architecture spi_slave_arch;
