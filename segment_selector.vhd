library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Segment_selector is
    Port ( score_sel : in STD_LOGIC_VECTOR (15 downto 0);
           T : in STD_LOGIC_VECTOR (1 downto 0);
           anode : out STD_LOGIC_VECTOR(3 downto 0);
           digit : out STD_LOGIC_VECTOR (3 downto 0));
end Segment_selector;

architecture Behavioral of Segment_selector is

begin
process(T, score_sel)
Begin
    case T is
        when "00" => 
            digit <= score_sel (3 Downto 0);
            anode <= "1110";
        when "01" => 
            digit <= score_sel (7 Downto 4);
            anode <= "1101";
        when "10" => 
            digit <= score_sel (11 Downto 8);
            anode <= "1011";
        when others => 
            digit <= score_sel (15 Downto 12);
            anode <= "0111";
        
     end case;
end process;

end Behavioral;
