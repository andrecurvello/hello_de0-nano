-- Universal Asynchronous Transmitter
-- TODO(aray): add reset handler (ask mark for best practices)
-- TODO(aray): share code for clock divider if possible
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic(
        clock_freq_hz : integer;
        baud_hz       : integer
    );
    port(
        clock  : in  std_logic;
        busy   : out std_logic;
        enable : in  std_logic;
        wire   : out std_logic;
        data   : in  std_logic_vector(7 downto 0)
    );
end uart_tx;

architecture uart_tx_arch of uart_tx is
    constant clk_counter_max : integer := clock_freq_hz / baud_hz;
    signal   clk_counter     : integer range 1 to clk_counter_max := 1;
    signal   tick            : std_logic := '0';
    signal   busy_reg        : std_logic := '0';
    signal   wire_reg        : std_logic := '1';
    signal   data_reg        : std_logic_vector(9 downto 0) := '0000000000';
begin
    busy <= busy_reg;
    wire <= wire_reg;

    -- TODO(aray): oh god clean up the nesting (See also TODO:Learn VHDL)
    clk_div : process( clock )
    begin
        if rising_edge( clock ) then
            if( busy_reg = '0' ) then -- no transmit in progress, check enable
                if( enable = '1' ) then -- time to start a new transmission
                    data_reg <= { 0 , -- start bit
                                data (7 downto 0) , -- data to shift out
                                1};   -- stop bit
                    busy_reg <= '1';  -- we're now busy, so...
                    clk_counter <= 1; -- reset clock counter, and...
                    tick <= '1';      -- tick out data right away!
                end if;
            else -- We have a transmit in progress, tick away!
                if( clk_counter < clk_counter_max ) then
                    clk_counter <= clk_counter + 1;
                    tick <= '0';
                else
                    clk_counter <= 1;
                    tick <= '1';
                end if;
            end if;
        end if;
    end process clk_div;

    tick_div : process( tick )
    begin
        if rising_edge( tick ) then
            -- XXX shift out data_reg to wire_reg 
            wire_reg <= data_reg(0);
            data_reg <= '0' & data_reg(9 downto 1);
        end if;
    end process tick_div;
end architecture uart_tx_arch;
