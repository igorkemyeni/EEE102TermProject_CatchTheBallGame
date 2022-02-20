library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Clock_divider is
    Port ( clk : in STD_LOGIC;
           cnt : out STD_LOGIC_vector (1 downto 0));
end Clock_divider;

architecture Behavioral of Clock_divider is
    signal counter : integer := 0;
    signal temp : std_logic_vector (1 downto 0);
    
begin
process(clk)
begin
    if rising_edge(clk) then
        if counter < 250000 then
            counter <= counter + 1;
        else
            counter <= 0;
            temp <= temp + "01";
        end if;
    end if;
end process;  
cnt <= temp;
              
end Behavioral;
