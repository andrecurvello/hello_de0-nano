-- Serial Peripheral Interface Bus - Master
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
  generic(
    fpga_clk_freq_hz : integer;    -- Internal FPGA clock rate
    sclk_freq_hz     : integer;    -- Spi Clock rate
    cpol             : std_logic;  -- Clock Polarity
    cpha             : std_logic   -- Clock Phase
  );
  port(
    -- Internal (FPGA) interface
    fpga_clock  : in  std_logic;  -- input clock
    enable      : in  std_logic;  -- initiates SPI transaction
    reset       : in  std_logic;  -- fpga_clock-sychronous reset
    busy        : out std_logic;  -- indicates SPI transaction in progress
    done        : out std_logic;  -- indicates SPI transaction complete
    data_tx     : in  std_logic_vector(7 downto 0);  -- data to transmit
    data_rx     : out std_logic_vector(7 downto 0);  -- data received

    -- External (SPI) interface
    sclk        : out std_logic;  -- Serial Clock
    mosi        : out std_logic;  -- Master Output, Slave Input
    miso        : in  std_logic;  -- Master Input, Slave Output
    ss_l        : out std_logic   -- Slave Select (active low)
  );
end spi_master;

architecture spi_master_arch of spi_master is
  constant clk_counter_max : integer := fpga_clk_freq_hz / (sclk_freq_hz * 2);
  signal   clk_counter     : integer range 1 to clk_counter_max := 1;
  signal   done_reg        : std_logic := '0';
  signal   data_tx_reg     : std_logic_vector(9 downto 0) := "0000000000";
  signal   data_rx_reg     : std_logic_vector(7 downto 0) := "00000000";
  signal   sclk_reg        : std_logic := cpol;
  signal   mosi_reg        : std_logic := '0';
  signal   ss_l_reg        : std_logic := '1';
begin  -- architecture spi_master_arch of spi_master
  done    <= done_reg;
  data_rx <= data_rx_reg;
  sclk    <= sclk_reg;
  mosi    <= data_tx_reg(9);
  ss_l    <= ss_l_reg;
  busy    <= not ss_l_reg;  -- simplification for now, may be changed later

  -- TODO(aray): oh crap clean up the nesting (See also TODO:Learn VHDL)
  clk_div : process(fpga_clock)
  begin
    if rising_edge(fpga_clock) then
      done_reg <= '0';  -- unless otherwise set below
      if (reset = '1') then  -- synchronous reset
        sclk_reg <= cpol;
        ss_l_reg <= '1';
      else
        if (ss_l_reg = '1') then  -- if no transaction in progress...
          if (enable = '1') then  -- ...start a new transaction
            if (cpha = '0') then
              data_tx_reg <= data_tx(7 downto 0) & '1' & '0';
              clk_counter <= 1;
            else  -- cpha = '1'
              data_tx_reg <= data_tx(7) & data_tx(7 downto 0) & '1';
              clk_counter <= clk_counter_max;  -- tick next fpga_clock
            end if;
            sclk_reg <= cpol;
            ss_l_reg <= '0';
          end if;
        else  -- transaction in progress
          if (clk_counter = clk_counter_max) then -- tick
            clk_counter <= 1;
            sclk_reg <= not sclk_reg;
            if ((cpol xor cpha xor sclk_reg) = '1') then  -- switch data time!
              if (data_tx_reg(8 downto 0) = "100000000") then  -- end of byte
                if (enable = '1') then -- continue transaction
                  data_tx_reg <= data_tx(7 downto 0) & '1' & '0';
                else
                  ss_l_reg <= '1';  -- done with transaction
                  sclk_reg <= cpol;
                end if;
                done_reg <= '1';  -- blip for one clk_div (sequential assignment)
              else  -- continue transaction
                data_tx_reg <= data_tx_reg(8 downto 0) & '0';  -- shift out
              end if;
            else  -- sample time!
              data_rx_reg <= data_rx_reg(6 downto 0) & miso;  -- shift in
            end if;
          else  -- count up to tick...
            clk_counter <= clk_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process clk_div;
end architecture spi_master_arch;
