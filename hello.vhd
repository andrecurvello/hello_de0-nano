-- Hello_DE0-Nano
library IEEE;
use IEEE.std_logic_1164.ALL;

entity hello is
	Port( CLOCK_50 : in std_logic;
		   LED : OUT std_logic_vector( 7 downto 0 ) );
end hello;

architecture Arch of hello is
	signal counter : integer range 0 to 25000000 := 0;
	signal led_buffer : std_logic := '0';
begin
	LED(0) <= led_buffer;
	clk_div  : process( CLOCK_50 )
	begin
		if rising_edge( CLOCK_50 ) then
			if( counter < 25000000 ) then
				counter <= counter + 1;
			else
				counter <= 0;
				led_buffer <= not led_buffer;
			end if;
		end if;
	end process;
end architecture;