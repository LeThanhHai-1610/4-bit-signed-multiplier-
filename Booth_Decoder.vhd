library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
entity Booth_Decoder is
port
(

	------------ CLOCK ------------
	CLOCK_50        	:in    	std_logic;
	
	------------ SW ------------
	SW              	:in    	std_logic_vector(9 downto 0);

	------------ LED ------------
	LEDR            	:out   	std_logic_vector(9 downto 0);

	------------ Seg7 ------------
	HEX0            	:out   	std_logic_vector(6 downto 0);
	HEX1            	:out   	std_logic_vector(6 downto 0);
	HEX2            	:out   	std_logic_vector(6 downto 0);
	HEX3            	:out   	std_logic_vector(6 downto 0);
	HEX4            	:out   	std_logic_vector(6 downto 0);
	HEX5            	:out   	std_logic_vector(6 downto 0)
);

end entity;

---------------------------------------------------------
--  Structural coding
---------------------------------------------------------


architecture rtl of Booth_Decoder is

-- declare --
signal x,y,xb,x1,y1 :       std_logic_vector(3 downto 0);
signal c		   	  :		 std_logic_vector(4 downto 0);
signal a, b         :    	 std_logic_vector(6 downto 0);
signal d            :       std_ulogic_vector(7 downto 0);
signal result       :       std_logic_vector(6 downto 0);
begin

-- body --
x <= SW(3 downto 0);
y <= SW(7 DOWNTO 4);
process(x,y)
begin
if (x(3) xor y(3)) = '1' then

	if (x(3) = '1') then x1 <= not(x) + '1'; else x1<=x; end if;
	if (y(3) = '1') then y1 <= not(y) + '1'; else y1<=y; end if;
	
else x1<=x; y1<=y;
end if;
end process;
-----

c <= y1 & '0';
xb <= not(x1) +'1';
process(c)
begin
  case c(2 downto 0) is
		when "000" => a <= "0000000";  
		when "001" => if (x1(3)='1') then a  <= "111" & x1; else a <= "000" & x1; end if;
		when "010" => if (x1(3)='1') then a  <= "111" & x1; else a <= "000" & x1; end if;
		when "011" => if (x1(3)='1') then a  <= "11"  & x1 & '0'; else a <= "00" & x1 & '0'; end if;
		when "100" => if (xb(3)='1') then a  <= "11"  & xb & '0'; else a <= "00" & xb & '0'; end if;
		when "101" => if (xb(3)='1') then a  <= "111" & xb; else a <= "000" & xb; end if;
		when "110" => if (xb(3)='1') then a  <= "111" & xb; else a <= "000" & xb; end if;
		when "111" => a <= "0000000";
	end case;
	case c(4 downto 2) is
		when "000" =>  b <= "0000000";  
		when "001" =>  if (x1(3)='1') then b  <='1' & x1 & "00"; else  b <=  '0' & x1 & "00"; end if;
		when "010" =>  if (x1(3)='1') then b  <='1' & x1 & "00"; else  b <=  '0' & x1 & "00"; end if;
		when "011" =>  b <= x1 & "000";
		when "100" =>  b <= xb & "000";
		when "101" =>  if (xb(3)='1') then b  <='1' & xb & "00"; else  b <=  '0' & xb & "00"; end if;
		when "110" =>  if (xb(3)='1') then b  <='1' & xb & "00"; else  b <=  '0' & xb & "00"; end if;
		when "111" =>  b <= "0000000";
	end case;
end process;

-----------------------7-bit ripple-carry adder--------------

d(0) <= '0';
G1: for m in 0 to 6 generate
result(m) <= a(m) xor b(m) xor d(m);
d(m+1) <= (a(m) and b(m)) or (b(m) and d(m)) or (a(m) and d(m));
end generate G1;
-------------------------------------------------------------
process(x,y,result)
begin
if (x(3) xor y(3)) = '1' then
	LEDR (6 downto 0) <= not(result) + '1'; else LEDR (6 downto 0) <= result; 
end if;
end process; 	

end rtl;

