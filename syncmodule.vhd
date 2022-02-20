library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sync_mod is
      Port ( clk         : in  STD_LOGIC;
                reset      : in  STD_LOGIC;
                start     : in  STD_LOGIC;
                y_cnt : out  STD_LOGIC_VECTOR (9 downto 0);
                x_cnt  : out  STD_LOGIC_VECTOR (9 downto 0);
                h_s          : out  STD_LOGIC;
                v_s           : out  STD_LOGIC;
               video_on : out  STD_LOGIC);
end sync_mod;

architecture Behavioral of sync_mod is
-- specifications
constant HGO:integer:=800;--Yatay görüntü
constant HFP:integer:=56;--Horizontal Front Porch
constant HBP:integer:=64;--Horizontal Back Porch
constant HGK:integer:=120;--Yatay geri kayma
constant VGO:integer:=600;--Düşey görüntü
constant VFP:integer:=37;--Vertical Front Porch
constant VBP:integer:=23;--Vertical Back Porch
constant VGK:integer:=6;--Düşey geri kayma
--sync cnters
signal count_h,count_h_next: integer range 0 to 1039;
signal count_v,count_v_next: integer range 0 to 665;
--mod 2 counter
signal counter_mod2,counter_mod2_next: std_logic:='0';
--state sigs
signal h_end, v_end:std_logic:='0';
--out signals -- buffers
signal hs_buffer,hs_buffer_next:std_logic:='0';
signal vs_buffer,vs_buffer_next:std_logic:='0';
--pixel counters
signal x_cn, x_cn_next:integer range 0 to 900;
signal y_cn, y_cn_next:integer range 0 to 900;
--video_on_of
signal video:std_logic;
begin
--register
   process(clk,reset,start)
       begin
          if reset ='1' then
              count_h<=0;
              count_v<=0;
              hs_buffer<='0';
              hs_buffer<='0';
              counter_mod2<='0';
         elsif clk'event and clk='1' and start = '1' then
              count_h<=count_h_next;
              count_v<=count_v_next;
               x_cn<=x_cn_next;
               y_cn<=y_cn_next;
               hs_buffer<=hs_buffer_next;
               vs_buffer<=vs_buffer_next;
               counter_mod2<=counter_mod2_next;
        end if;
end process;
--video on/off
       video <= '1' when  (count_v >= VBP) and (count_v < VBP + VGO) and (count_h >=HBP) and (count_h < HBP + HGO)
                             else  '0';

--mod 2 cnter
       counter_mod2_next<=not counter_mod2;
-- horizontal cnt end
       h_end<= '1' when count_h=1039 else --(HGO+HFP+HBP+HGK-1)
                         '0';       
-- vertical cnt end
      v_end<= '1' when count_v=665 else --(VGO+VFP+VBP+VGK-1)
                      '0'; 
-- horizontal counter
process(count_h,counter_mod2,h_end)
    begin
       count_h_next<=count_h;
       if  counter_mod2= '1' then
           if h_end='1' then
               count_h_next<=0;
           else
               count_h_next<=count_h+1;
          end if;
     end if;
  end process;

-- vertical counter
process(count_v,counter_mod2,h_end,v_end)
   begin        
      count_v_next <= count_v;
      if  counter_mod2= '1' and h_end='1'  then
         if v_end='1' then
             count_v_next<=0;
         else
              count_v_next<=count_v+1;
         end if;
       end if;
   end process;

--pixel x counter
process(x_cn,counter_mod2,h_end,video)
    begin       
       x_cn_next<=x_cn;
       if video = '1' then
           if  counter_mod2= '1' then                            
               if x_cn= 799 then
                   x_cn_next<=0;
               else
                  x_cn_next<=x_cn + 1;
             end if;
         end if;
    else
       x_cn_next<=0;
   end if;
end process;

--pixel y scounter
process(y_cn,counter_mod2,h_end,count_v)
    begin        
       y_cn_next<=y_cn;
       if  counter_mod2= '1' and h_end='1' then
          if count_v >22 and count_v <622  then
              y_cn_next<=y_cn + 1;
         else
             y_cn_next<=0;                           
         end if;
     end if;
end process;

--buffer
hs_buffer_next<= '1' when count_h < 920 else --(HBP+HGO+HFP)
                                 '0';
vs_buffer_next<='1' when count_v < 660 else --(VBP+VGO+VFP)
                               '0';       

 --outs
y_cnt <= conv_std_logic_vector(y_cn,10);
x_cnt <= conv_std_logic_vector(x_cn,10);
h_s<= hs_buffer;
v_s<= vs_buffer;
video_on<=video;

end Behavioral;
