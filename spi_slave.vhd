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
  signal   miso_reg        : std_logic := '0';
  signal   clk_reg         : std_logic := '0';
begin  -- architecture spi_slave_arch of spi_slave
  done    <= done_reg;
  data_rx <= data_rx_reg;
  miso    <= data_tx_reg(7);
  clk_reg <= (cpol xor cpha xor sclk);

  -- TODO(aray): oh crap clean up the nesting (See also TODO:Learn VHDL)
  spi_div : process(ss_l, clk_reg)
  begin
    done_reg <= '0';
    if (ss_l = '1') then
      -- TODO: no conditionals in here
      -- TODO: this check isn't valid since you can get SS_L before last sample
      -- TODO: twiddle 'done_reg' at last sample
      -- TODO: put sentinel in 'data_rx_reg'
      if (data_tx_reg = "100000000") then  -- successfully finished
        done_reg <= '1';
      end if;
      data_tx_reg <= "000000000";
    else
      if (data_tx_reg = "000000000") then  -- start time!
        -- TODO: ken says get rid of this
        data_tx_reg <= data_tx & '1';                   -- latch in
      end if;

      if rising_edge(clk_reg) then      -- sample time!
        data_rx_reg <= data_rx_reg(6 downto 0) & mosi;  -- shift in
      end if;
      -- TODO: bring up RTL viewer, make sure this is sensible
      if falling_edge(clk_reg) then     -- switch time!
        data_tx_reg <= data_tx_reg(7 downto 0) & '0';   -- shift out
      end if;
    end if;
  end process spi_div;
end architecture spi_slave_arch;
