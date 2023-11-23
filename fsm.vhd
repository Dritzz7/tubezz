library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;

entity fsm is
	port(	rst, clk: in std_logic;
			inputCount: out std_logic;		-- buat enable count biar naik
			resetCounter : out std_logic;
			counter : in std_logic_vector(3 downto 0);
			comparison: in std_logic; -- 0: angle<Sudut. 1: angle>=Sudut.
			en_Subtractor: out std_logic;
			en_Register: out std_logic;
			reset_Register: out std_logic;
			modeSin, modeCos, modeTan : in std_logic;
			outFinal: out std_logic
	);
end fsm;

architecture fsm_arc of fsm is
	type state is (s0, s1, s2, s3, s4, s5); -- s0: inisialisasi, s1: angle < inputSudut, s2: angle >= inputSudut, s3: save di register. s4 buat compare.
									   -- setelah di s1 atau s2, akan ada penyetaraan bit. s5 buat outFinal.
	signal currentState : state;-- := s0;
	signal nextState : state;-- := s0;
	
	--signal modeSin, modeCos, modeTan : std_logic;
	signal statusCount : std_logic;-- := '1';
	signal statusResetCounter : std_logic;-- := '0';
	
begin
	process(rst, clk, currentState, nextState, statusCount, statusResetCounter)
	begin
	if (rst = '1') then
		currentState <= s0;
		resetCounter <= '1';
		inputCount <= '0';
	elsif (clk'EVENT and clk = '1') then
		currentState <= nextState;
		inputCount <= statusCount;
		resetCounter <= statusResetCounter;
	end if;
	end process;
	
	process(comparison, currentState, statusResetCounter, statusCount)
	begin
	
	case currentState is
	
		when s0 =>
			--if (modeSin = '0' and modeCos = '0' and modeTan = '0') then  -- pas disimulasiin, pencet reset dulu sekali
			--	reset_Register <= '1';		-- x diset ke 1, y ke 0, angle ke 0
			--	statusResetCounter <= '1';
			--	statusCount <= '0';
			--	en_Subtractor <= '0';
			--	en_Register <= '0';
			--	outFinal <= '0';
			--	nextState <= s0;
			if (modeSin = '1' or modeCos = '1' or modeTan = '1') then
				reset_Register <= '1';
				statusResetCounter <= '0';
				statusCount <= '0';
				en_Subtractor <= '0';
				en_Register <= '0';
				outFinal <= '0';
				nextState <= s4;
			end if;
			
		when s4 =>							-- buat compare
			reset_Register <= '0';			-- kalo reset gk aktif, register bakal nge-copy input
			statusCount <= '0';
			statusResetCounter <= '0';
			en_Subtractor <= '0';
			en_Register <= '0';
			outFinal <= '0';
			if (comparison = '0') then		-- angle < Sudut
				nextState <= s1;
			elsif (comparison = '1') then	-- angle >= Sudut
				nextState <= s2;
			end if;

		when s1 =>
			reset_Register <= '0';			-- x = x - ... . y = y + ... . angle = angle + ...
			en_Subtractor <= '1';
			statusCount <= '0';
			statusResetCounter <= '0';
			en_Register <= '0';
			outFinal <= '0';
			nextState <= s3;		-- save di register

		when s2 =>							-- x = x + ... . y = y - ... . angle = angle - ...
			reset_Register <= '0';
			en_Subtractor <= '1';
			statusCount <= '0';
			statusResetCounter <= '0';
			en_Register <= '0';
			outFinal <= '0';
			nextState <= s3;		-- save di register

		when s3 =>		-- save di register
			en_Subtractor <= '0';
			reset_Register <= '0';
			outFinal <= '0';
			en_Register <= '1';
			
			if (counter >= "1101") then
				statusCount <= '0';
				statusResetCounter <= '1';
				nextState <= s5; -- outFinal
			else
				statusCount <= '1';
				statusResetCounter <= '0';
				nextState <= s4;
			end if;
		
		when s5 =>			-- outFinal
			en_Subtractor <= '0';
			reset_Register <= '0';
			en_Register <= '0';
			statusCount <= '0';
			statusResetCounter <= '1';
			outFinal <= '1';			-- register OUT_REG aktif			
			nextState <= s0;			-- if modeSin = '1' ... --> tulis di top level	
			
		when others =>
			nextState <= s0;
	
	end case;
	
	end process;

end fsm_arc;