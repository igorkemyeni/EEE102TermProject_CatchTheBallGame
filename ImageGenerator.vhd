library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity image_generator is
     Port ( clk              : in  STD_LOGIC;
                glob_reset        : in std_logic; -- also start-stop input from user
                x_counter    : in  STD_LOGIC_VECTOR(9 downto 0);
                button_l    :in STD_LOGIC;
                button_r    :in STD_LOGIC;
                y_counter    : in STD_LOGIC_VECTOR(9 downto 0);
                video_on  : in  STD_LOGIC;
                rgb        : out  STD_LOGIC_VECTOR(2 downto 0);
                x_y_in :     in std_logic_vector(7 downto 0); -- random number input from pseudorng module
                score: out std_logic_vector(15 downto 0);
                lives: out std_logic_vector(1 downto 0));
                
    end image_generator;

architecture Behavioral of image_generator is

--bottom bar
signal bar_l,bar_l_next:integer :=100; --bar's x
constant bar_t:integer :=590;--bar's y
constant bar_k:integer :=10;--barın thickness
signal bar_w, bar_w_next:integer:=120;--bar width
constant bar_h:integer:=7;--bar speed
signal bar_on:std_logic;
signal rgb_bar:std_logic_vector(2 downto 0);

--left bar
signal bar_l_2,bar_l_2_next:integer :=90; --bar's x
constant bar_t_2:integer :=490;--bar's y
constant bar_k_2:integer :=100;--bar height
constant bar_w_2:integer:=10;--bar width
constant bar_h_2:integer:=7;--bar speed
signal bar_on_2:std_logic;
signal rgb_bar_2:std_logic_vector(2 downto 0);
--right bar
signal bar_l_3,bar_l_3_next:integer :=220; --bar's x
constant bar_t_3:integer :=490;--bar's y
constant bar_k_3:integer :=100;--barın thickness
constant bar_w_3:integer:=10;--bar widht
constant bar_h_3:integer:=7;--bar's speed
signal bar_on_3:std_logic;
signal rgb_bar_3:std_logic_vector(2 downto 0);

--ball
signal ball_l,ball_l_next:integer :=100;--ball x
signal ball_t,ball_t_next:integer :=100; --ball y
signal ball_r:integer :=10; -- ball radius
constant x_v,y_v:integer:=2;-- ball's x-y velocity
signal ball_on:std_logic;
signal rgb_ball:std_logic_vector(2 downto 0); 

--refresh(1/72)
signal refresh_reg,refresh_next:integer;
constant refresh_constant:integer:=691666;
signal refresh_tick:std_logic;

--top animasyon
signal xv_reg,xv_next:integer:=2;--horizontal speed variable
signal yv_reg,yv_next:integer:=2;--vertical speed variable

--x,y pixel signal
signal x,y:integer range 0 to 810;

--mux
signal mux:std_logic_vector(4 downto 0);

--score
signal score_reg, score_next: std_logic_vector(15 downto 0);
signal score_sig, score_sig_next : std_logic_vector(10 downto 0);
-- lives
signal  lives_reg, lives_left_next: std_logic_vector(1 downto 0) := "11";
-- if lives left = 0
signal lose_state : std_logic := '0';

--buffer
signal rgb_reg,rgb_next:std_logic_vector(2 downto 0);

begin

--x,y pixel marker
x <=conv_integer(x_counter);
y <=conv_integer(y_counter );

--refresh time
process(clk)
    begin            
        if clk'event and clk='1' then
             refresh_reg<=refresh_next;      
        end if;
    end process;

refresh_next<= 0 when refresh_reg= refresh_constant else
                           refresh_reg+1;
refresh_tick<= '1' when refresh_reg = 0 else '0';

--register
process(clk)
    begin
        
    
        if clk'event and clk='1' then
            if glob_reset = '1' then
                  
                  ball_l <= 100;
                  ball_t <= 100;
                  bar_l <= 100;
                  bar_l_2 <= 90;
                 -- bar_l_3 <= 220;
                  bar_w <= 120;
                  score_sig <= "00000000000";
                  score_reg <= "0000000000000000";
                  lives_reg <= "11";
            else
                if lose_state = '0' then
                      ball_l<=ball_l_next;
                      ball_t<=ball_t_next;
                      xv_reg<=xv_next;
                      yv_reg<=yv_next;
                      bar_l<=bar_l_next;
                      bar_w <= bar_w_next;
                      bar_l_2 <= bar_l_2_next;
                     -- bar_l_3 <= bar_l_3_next;
                      lives_reg <= lives_left_next;
                      score_reg <= score_next;
                      score_sig <= score_sig_next;
                else
                      
                      ball_l <= 100;
                      ball_t <= 100;
                      bar_l <= 100;
                      bar_l_2 <= 90;
                      
                     -- bar_l_3 <= 220;
                      bar_w <= 120;
                      score_sig <= score_sig_next;
                      score_reg <= score_next;
                end if;
             end if;
    end if;
end process;


--bar animation and level process
bar_l_3_next <= bar_l_2_next + bar_w_next + 10;
bar_l_3 <= bar_l_2 + bar_w + 10;
process(bar_l,bar_l_2, bar_l_3,refresh_tick,button_r,button_l)
    begin
         bar_l_next<=bar_l;
         bar_l_2_next<= bar_l_2;
         bar_w_next <= bar_w;
         if refresh_tick= '1' then
             if button_l='1' and bar_l > bar_h and bar_l_2 > bar_h_2  then
                   bar_l_next<=bar_l- bar_h;
                   bar_l_2_next<=bar_l_2 - bar_h_2;
             elsif button_r='1' and bar_l < (799- bar_h-bar_w)and bar_l_2 < (789-bar_h_2-bar_w_2)  then
                   bar_l_next<=bar_l+ bar_h;
                   bar_l_2_next<=bar_l_2+ bar_h_3;
             end if;
                     
             if conv_integer(score_sig) > 10 and conv_integer(score_sig) < 81 then
                   bar_w_next <= 120 - conv_integer(score_sig(10 downto 1));
                   
             elsif conv_integer(score_sig) > 81 then
                   bar_w_next <= 80;
                   
             end if;
                
         end if;
   end process;

--ball, score and,lives_left animation
process(refresh_tick,ball_l,ball_t,xv_reg,yv_reg)
    begin
         ball_l_next <=ball_l;
         ball_t_next <=ball_t;
         xv_next<=xv_reg;
         yv_next<=yv_reg;
         score_next <= score_reg;
         score_sig_next <= score_sig;
         lives_left_next <= lives_reg;
         if refresh_tick = '1' then
                         
                if ball_l < 10 then --when ball touched the left 
                       xv_next<= x_v;
                elsif ball_l> 760 then                
                       xv_next<= -x_v ;         --when ball touched the right
                end if;   
                if ball_t+(ball_r*2) > 520 then
                    if ball_l > (bar_l_2+bar_w_2) and ball_l < (bar_l_3-ball_r*2) then 
                    
                        ball_t_next <= conv_integer(x_y_in)/2;
                        ball_l_next <= (conv_integer(x_y_in)/2)*(5); 
                        score_sig_next <= score_sig + 1;    
                        score_next(3 downto 0) <= score_reg(3 downto 0) + 1; -- ball inside the cup 
                            if conv_integer(score_reg(3 downto 0)) = 9 then
                                score_next(3 downto 0) <= "0000";
                                score_next(7 downto 4) <= score_reg(7 downto 4) +1;
                                if conv_integer(score_reg(7 downto 4)) = 9 then
                                    score_next(7 downto 4) <= "0000";
                                    score_next(11 downto 8) <= score_reg(11 downto 8) +1;
                                    if conv_integer(score_reg(11 downto 8)) = 9 then
                                        score_next(11 downto 8) <= "0000";
                                        score_next(15 downto 12) <= score_reg(15 downto 12) +1;
                                    end if;
                                end if;
                            end if;
                        
                    else 
                        ball_t_next <= 50;
                        ball_l_next <= 400;
                        lives_left_next <= (lives_reg - 1);
                    end if;

                else
                    ball_l_next <=ball_l +xv_next;
                    ball_t_next <=ball_t+yv_next;    
                end if;    
                
                if glob_reset = '1' then
                    lose_state <= '0';
                elsif lives_reg = "00" then
                    lose_state <= '1';
                end if;
                          
       end if;
       
   end process;  





--bar object
bar_on <= '1' when x > bar_l and x < (bar_l+bar_w) and y> bar_t and y < (bar_t+ bar_k) else '0';
rgb_bar<="001";--blue
--vertical bar 1
bar_on_2 <= '1' when x > bar_l_2 and x < (bar_l_2+bar_w_2) and y> bar_t_2 and y < (bar_t_2+ bar_k_2) else '0';
rgb_bar_2<="001";
--vertical bar2
bar_on_3 <= '1' when x > bar_l_3 and x < (bar_l_3+bar_w_3) and y> bar_t_3 and y < (bar_t_3+ bar_k_3) else '0';
rgb_bar_3<="001";

-- ball object
ball_on <= '1' when (x - ball_l) * (x - ball_l) + (y - ball_t) * (y - ball_t) <= ball_r * ball_r else
           '0';

rgb_ball<="010";  --green  

--buffer
process(clk)
     begin
         if clk'event and clk='1' then
              rgb_reg<=rgb_next;
         end if;
     end process;

--mux
mux <= video_on & bar_on & ball_on & bar_on_2 & bar_on_3;     
with mux select
                           rgb_next <="100"  when "10000",--red, background
                           rgb_bar          when "11000",
                           rgb_bar          when "11100",
                           rgb_bar_2        when "10010",
                           rgb_bar_2        when "10110",
                           rgb_bar_3        when "10001",
                           rgb_bar_3        when "10101",
                           rgb_ball          when "10100",
                           "000"               when others;
--output
rgb<=rgb_reg;
score <= score_reg;
lives <= lives_reg;
end Behavioral;
