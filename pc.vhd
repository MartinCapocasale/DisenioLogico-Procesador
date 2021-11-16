-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pc is
  port (   
        clk         : in  std_logic;
        rst         : in  std_logic;
        output      : out std_logic_vector(6 downto 0);
        );    
end pc;
   
architecture pc_arqui of pc is
  
begin
     
process (clk,rst) is
   
   begin
     if(rst = '1')then
     
        output  <= (others => '0');
      
      elsif (clk'event and clk = '1') then
      
        output  <= output + 1 ;
              
      end if;   
       
end process;

