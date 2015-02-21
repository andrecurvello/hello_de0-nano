-- Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "02/21/2015 14:27:06"
                                                            
-- Vhdl Test Bench template for design  :  hello
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;    
USE ieee.numeric_std.all;
                            

ENTITY hello_vhd_tst IS
END hello_vhd_tst;
ARCHITECTURE hello_arch OF hello_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL CLOCK_50 : STD_LOGIC;
SIGNAL LED : STD_LOGIC_VECTOR(7 DOWNTO 0);
COMPONENT hello
	PORT (
	CLOCK_50 : IN STD_LOGIC;
	LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

-- test bench clock
	constant clock_50_period : time := 20 ns;

BEGIN
	i1 : hello
	PORT MAP (
-- list connections between master ports and signals
	CLOCK_50 => CLOCK_50,
	LED => LED
	);
	
-- generate test bench clock
clk_gen : process
-- no variables here
begin
	loop
		CLOCK_50 <= '1';	wait for clock_50_period/2;
		CLOCK_50 <= '0';	wait for clock_50_period/2;
	end loop;
end process;
	
init : PROCESS                                    
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
	
WAIT;                                                        
END PROCESS always;                                          
END hello_arch;
