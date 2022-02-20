library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_module is
    Port (     clk : in  STD_LOGIC;
               start       : in  STD_LOGIC;
               glob_reset : in std_logic;
               reset        : in  STD_LOGIC;
               button_l   : IN std_logic;
               button_r   : IN std_logic;
               rgb            : out  STD_LOGIC_VECTOR (2 downto 0);
               h_s           : out  STD_LOGIC;
               v_s            : out  STD_LOGIC;
               segments : out std_logic_vector(6 downto 0);
               anode : out std_logic_vector(3 downto 0);
               LED1: out std_logic;
               LED2: out std_logic;
               LED3: out std_logic);
     end top_module;

architecture Behavioral of top_module is

COMPONENT image_generator
   PORT(        clk : IN std_logic;
                glob_reset: in std_logic;
                x_counter    : IN std_logic_vector(9 downto 0);
                button_l     : IN std_logic;
                button_r     : IN std_logic;
                y_counter     : IN std_logic_vector(9 downto 0);
                video_on   : IN std_logic;         
                rgb              : OUT std_logic_vector(2 downto 0);
                x_y_in :     in std_logic_vector(7 downto 0);
                score:       out std_logic_vector(15 downto 0);
                lives: out std_logic_vector(1 downto 0));
  END COMPONENT;

COMPONENT sync_mod
PORT(        clk  : IN std_logic;
             reset        : IN std_logic;
             start       : IN std_logic;         
             y_cnt   : OUT std_logic_vector(9 downto 0);
             x_cnt   : OUT std_logic_vector(9 downto 0);
             h_s           : OUT std_logic;
             v_s            : OUT std_logic;
             video_on   : OUT std_logic );
END COMPONENT;

component pseudorng
port ( clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       Q : out STD_LOGIC_VECTOR (7 downto 0)
       );
end component;

component Clock_divider is
    Port ( clk : in STD_LOGIC;
           cnt : out STD_LOGIC_vector (1 downto 0));
end component;

component SegmentDecoder is
    Port ( digit : in STD_LOGIC_VECTOR (3 downto 0);
           ledo : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component Segment_selector is
    Port ( score_sel : in STD_LOGIC_VECTOR (15 downto 0);
           T : in STD_LOGIC_VECTOR (1 downto 0);
           anode : out STD_LOGIC_VECTOR(3 downto 0);
           digit : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal x,y:std_logic_vector(9 downto 0);
signal video:std_logic;
signal x_y_sig : std_logic_vector(7 downto 0);
signal T : std_logic_vector(1 downto 0);
signal digit: std_logic_vector ( 3 downto 0);
signal scoresig: std_logic_vector (15 downto 0);
signal lives: std_logic_vector(1 downto 0);


begin
U1: image_generator PORT MAP( clk =>clk ,  x_counter => x, button_l =>button_l  , button_r => button_r, y_counter => y,
                                             video_on =>video , rgb => rgb, x_y_in => x_y_sig, score => scoresig, lives => lives, glob_reset => glob_reset );

U2: sync_mod PORT MAP( clk => clk, reset => reset, start => start, y_cnt => y, x_cnt =>x , h_s => h_s ,
                                              v_s => v_s, video_on =>video );
                                              
U3: pseudorng PORT MAP (clk => clk, reset => reset, Q => x_y_sig);

U4:Clock_divider PORT MAP( clk => clk, cnt => T);

U5: SegmentDecoder PORT MAP (digit => digit, ledo => segments);

U6:Segment_selector PORT MAP( score_sel => scoresig, T => T, anode => anode, digit => digit);


lives_with_leds: process(lives)
begin 
    if lives = "11" then
        LED1 <= '1';
        LED2 <= '1';
        LED3 <= '1';
    elsif lives = "10" then
        LED1 <= '1';
        LED2 <= '1';
        LED3 <= '0';
    ELSIF lives = "01" then
        LED1 <= '1';
        LED2 <= '0';
        LED3 <= '0';
    ELSE 
        LED1 <= '0';
        LED2 <= '0';
        LED3 <= '0';
    end if;
end process;

end Behavioral;
