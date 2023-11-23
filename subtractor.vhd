library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity subtractor is
	port(	x, y : in std_logic_vector(31 downto 0);
			comparison : in std_logic;
			angle : in std_logic_vector(31 downto 0);
			counter : in std_logic_vector(3 downto 0); --std_logic_vector(3 downto 0);
			x_out, y_out : out std_logic_vector(31 downto 0);
			angle_out : out std_logic_vector(31 downto 0);
			clk : in std_logic;
			En_Subtractor : in std_logic
	);
end subtractor;

architecture subtractor_arc of subtractor is
	
	signal a: std_logic_vector(31 downto 0);  -- (2**-i)*y*d = a
	signal b: std_logic_vector(31 downto 0);  -- (2**-i)*x*d = b
	
	signal x_outTemp, y_outTemp: std_logic_vector(32 downto 0);
	signal angle_outTemp: std_logic_vector(32 downto 0);
	signal kCount : integer := to_integer(unsigned(counter));
	signal tanInv: std_logic_vector(31 downto 0) ; --:= tan_inv(counter);
	
	
	begin
	process(a, b, x, y, comparison, x_outTemp, y_outTemp, angle_outTemp, kCount, tanInv)

	begin
	
	if (En_Subtractor = '1' and rising_edge(clk) ) then

		if kCount = 1 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30) <= '0';
			a(29 downto 0) <= y(30 downto 1);
			b(30) <= '0';
			b(29 downto 0) <= x(30 downto 1);
		elsif kCount = 0 then
			a <= y;
			b <= x;
		elsif kCount = 2 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 29) <= "00";
			b(30 downto 29) <= "00";
			a(28 downto 0) <= y(30 downto 2);
			b(28 downto 0) <= x(30 downto 2);
		elsif kCount = 3 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 28) <= "000";
			b(30 downto 28) <= "000";
			a(27 downto 0) <= y(30 downto 3);
			b(27 downto 0) <= x(30 downto 3);
		elsif kCount = 4 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 27) <= "0000";
			b(30 downto 27) <= "0000";
			a(26 downto 0) <= y(30 downto 4);
			b(26 downto 0) <= x(30 downto 4);
		elsif kCount = 5 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 26) <= "00000";
			b(30 downto 26) <= "00000";
			a(25 downto 0) <= y(30 downto 5);
			b(25 downto 0) <= x(30 downto 5);
		elsif kCount = 6 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 25) <= "000000";
			b(30 downto 25) <= "000000";
			a(24 downto 0) <= y(30 downto 6);
			b(24 downto 0) <= x(30 downto 6);
		elsif kCount = 7 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 24) <= "0000000";
			b(30 downto 24) <= "0000000";
			a(23 downto 0) <= y(30 downto 7);
			b(23 downto 0) <= x(30 downto 7);
		elsif kCount = 8 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 23) <= "00000000";
			b(30 downto 23) <= "00000000";
			a(22 downto 0) <= y(30 downto 8);
			b(22 downto 0) <= x(30 downto 8);
		elsif kCount = 9 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 22) <= "000000000";
			b(30 downto 22) <= "000000000";
			a(21 downto 0) <= y(30 downto 9);
			b(21 downto 0) <= x(30 downto 9);
		elsif kCount = 10 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 21) <= "0000000000";
			b(30 downto 21) <= "0000000000";
			a(20 downto 0) <= y(30 downto 10);
			b(20 downto 0) <= x(30 downto 10);
		elsif kCount = 11 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 20) <= "00000000000";
			b(30 downto 20) <= "00000000000";
			a(19 downto 0) <= y(30 downto 11);
			b(19 downto 0) <= x(30 downto 11);
		elsif kCount = 12 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 19) <= "000000000000";
			b(30 downto 19) <= "000000000000";
			a(18 downto 0) <= y(30 downto 12);
			b(18 downto 0) <= x(30 downto 12);
		elsif kCount = 13 then
			a(31) <= y(31);
			b(31) <= x(31);
			a(30 downto 18) <= "0000000000000";
			b(30 downto 18) <= "0000000000000";
			a(17 downto 0) <= y(30 downto 13);
			b(17 downto 0) <= x(30 downto 13);
			
			
			
		else
			a <= (others => '0');
			b <= (others => '0');
			
			
			for i in 30 downto (31 - kCount) loop
				a(i) <= '0';
				b(i) <= '0';
			end loop;
			       -- FALSE JGN IKUTIN a(30 downto ((31 - kCount))) <= (others => '0');
			a((30 - kCount) downto 0) <= y(30 downto kCount);
			       -- FALSE JGN IKUTIN b(30 downto (31 - kCount)) <= (others => '0');
			b((30 - kCount) downto 0) <= x(30 downto kCount);	
			
				
		end if;
		
		
		if (kCount = 0) then
			tanInv <= "00101101000000000000000000000000";
		elsif (kCount = 1) then
			tanInv <= "00011010100100001010001111010111";
		elsif (kCount = 2) then
			tanInv <= "00001110010111000010100011110101";
		elsif (kCount = 3) then
			tanInv <= "00000111001000000000000000000000";
		elsif (kCount = 4) then
			tanInv <= "00000011100100110111010010111100";
		elsif (kCount = 5) then
			tanInv <= "00000001110010100011110101110000";
		elsif (kCount = 6) then
			tanInv <= "00000000111001010001111010111000";
		elsif (kCount = 7) then
			tanInv <= "00000000011100101011000000100000";
		elsif (kCount = 8) then
			tanInv <= "00000000001110010101100000010000";
		elsif (kCount = 9) then
			tanInv <= "00000000000111001010110000001000";
		elsif (kCount = 10) then
			tanInv <= "00000000000011100101011000000100";
		elsif (kCount = 11) then
			tanInv <= "00000000000001110010101100000010";
		elsif (kCount = 12) then
			tanInv <= "00000000000000111001010110000001";
		elsif (kCount = 13) then
			tanInv <= "00000000000000011100101011000000";
		else
			tanInv <= "00000001000000000000000000000000";
		end if;		
		
		
		-- a dan b sudah dibuat. Berati tinggal x = x +- a, y = y +- b, dan angle = angle +- tan_inv
			if comparison = '0' then	-- angel < Sudut
				x_outTemp <= ((x(31)& x) - (a(31)& a));
				y_outTemp <= ((y(31)& y) + (b(31)& b));
				angle_outTemp <= ((angle(31)& angle) + (tanInv(31)& tanInv));
				
			elsif comparison = '1' then	-- angle >= Sudut
				x_outTemp <= ((x(31)& x) + (a(31)& a));
				y_outTemp <= ((y(31)& y) - (b(31)& b));
				angle_outTemp <= ((angle(31)& angle) - (tanInv(31)& tanInv));
				
			end if;
			
		
			
		-- PENYETARAAN BIT
		x_out(31) <= x_outTemp(32);
		x_out(30) <= x_outTemp(31);
		x_out(29 downto 0) <= x_outTemp(30 downto 1);  -- x dan y : 1 1 30
		
		y_out(31) <= y_outTemp(32);
		y_out(30) <= y_outTemp(31);
		y_out(29 downto 0) <= y_outTemp(30 downto 1); 	-- angle : 1 7 24
		
		angle_out(31) <= angle_outTemp(32);
		angle_out(30 downto 24) <= angle_outTemp(31 downto 25);  -- bit ke 24 diskip (integer part)
		angle_out(23 downto 0) <= angle_outTemp(23 downto 0);
		
	end if;
	end process;
	

end subtractor_arc;