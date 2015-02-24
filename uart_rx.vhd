-- Universal Asynchronous Receiver
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic(
        clock_freq_hz : integer; -- frequency of the clock
        baud_hz       : integer  -- baudrate designed for this UART
    );
    port(
        clock  : in  std_logic; -- clock input
        reset  : in  std_logic; -- clock-synchronous reset
        wire   : in  std_logic; -- UART Rx wire
        busy   : out std_logic; -- is a receive in progress?
        valid  : out std_logic; -- is data valid? (will go low between bytes)
        data   : out std_logic_vector(7 downto 0) -- received data (when valid)
    );
end uart_rx;

architecture uart_rx_arch of uart_rx is
    constant clk_counter_max  : integer := clock_freq_hz / baud_hz;
    constant clk_counter_half : integer := clk_counter_max / 2;
    signal   clk_counter      : integer range 1 to clk_counter_max := 1;
    signal   busy_reg         : std_logic := '0';
    signal   valid_reg        : std_logic := '0';
    signal   data_reg         : std_logic_vector(9 downto 0) := "1111111111";
begin -- architecture uart_rx_arch
    busy  <= busy_reg;
    valid <= valid_reg;
    data  <= data_reg(8 downto 1); -- without start/stop bit

    -- TODO(aray): oh god clean up the nesting (See also TODO:Learn VHDL)
    clk_div : process (clock)
    begin
        if rising_edge (clock) then
            if (reset = '1') then
                busy_reg <= '0';
                data_reg <= "1111111111";
            else
                if (busy_reg = '0') then -- no receive in progress
                    if (wire = '0') then -- start bit!
                        busy_reg <= '1';
                        valid_reg <= '0';
                        data_reg <= "1111111111"; -- done when 0 gets to the top
                        clk_counter <= clk_counter_half; -- sample halfway
                    end if;
                else -- We have a transmit in progress
                    if (clk_counter < clk_counter_max) then
                        clk_counter <= clk_counter + 1; -- count up to tick
                    else
                        if (wire = '1') and (data_reg = "1111111111") then
                            busy_reg <= '0'; -- first bit wasnt 0, bail out
                        else -- TODO: reset out if first sample is not '0'
                            clk_counter <= 1; -- wraparound
                            data_reg <= data_reg(8 downto 0) & wire;
                            if (data_reg(9) = '0') then -- done!
                                if (data_reg(0) = '1') then -- check stop bit
                                    valid_reg <= '1';
                                else -- TODO convert 'data(0) = 1' to valid_reg
                                    valid_reg <= '0';
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process clk_div;
end architecture uart_rx_arch;
