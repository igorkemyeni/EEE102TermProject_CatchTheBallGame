library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SegmentDecoder is
    Port ( digit : in STD_LOGIC_VECTOR (3 downto 0);
           ledo : out STD_LOGIC_VECTOR (6 downto 0));
end SegmentDecoder;

architecture Behavioral of SegmentDecoder is

begin

Process(digit)

begin
        case digit is
            when "0000" => ledo <= "0000001"; --0
            when "0001" => ledo <= "1001111"; --"1"
            when "0010" => ledo <= "0010010"; --"2"
            when "0011" => ledo <= "0000110"; --"3"
            when "0100" => ledo <= "1001100"; --"4"
            when "0101" => ledo <= "0100100"; --"5"
            when "0110" => ledo <= "0100000"; --"6"
            when "0111" => ledo <= "0001111"; --"7"
            when "1000" => ledo <= "0000000"; --"8"
            when "1001" => ledo <= "0000100"; --"9"
            when others => ledo <= "0111000"; --F
--        when "1010" => ledo <= "0001000"; --A  
--        when "1011" => ledo <= "1100000"; --B  
--        when "1100" => ledo <= "0110001"; --C  
--        when "1101" => ledo <= "1000010"; --D  
--        when "1110" => ledo <= "0110000"; --E  
--        when "1111" => ledo <= "0111000"; --F
       
        END case;
end process;
end Behavioral;
