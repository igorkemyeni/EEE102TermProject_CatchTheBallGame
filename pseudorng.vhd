library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pseudorng is
Port ( clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       Q : out STD_LOGIC_VECTOR (7 downto 0));

end pseudorng;

architecture Behavioral of pseudorng is


signal Qt: STD_LOGIC_VECTOR(7 downto 0) := x"01";

begin

PROCESS(clk)
variable tmp : STD_LOGIC := '0';
BEGIN

IF rising_edge(clk) THEN
   IF (reset='1') THEN
      Qt <= x"01"; 
   ELSE
      tmp := Qt(4) XOR Qt(3) XOR Qt(2) XOR Qt(0);
      Qt <= tmp & Qt(7 downto 1);
   END IF;
END IF;
END PROCESS;
Q <= Qt;
end Behavioral;
