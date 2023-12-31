library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use work.all;

entity tubesTopLevel is
	port(	clk, rst: in std_logic;
			modeSin, modeCos, modeTan: in std_logic;
			Sudut: in std_logic_vector(31 downto 0);
			angka: out std_logic_vector(31 downto 0)
	);
end tubesTopLevel;

architecture tTL_arc of tubesTopLevel is

component fsm is
	port(	rst, clk: in std_logic;
			inputCount: out std_logic;		-- buat enable count biar naik
			resetCounter : out std_logic;
			counter : in std_logic_vector(3 downto 0);
			comparison: in std_logic; -- 0: angle<Sudut. 1: angle>=Sudut.
			en_Subtractor: out std_logic;
			en_Register: out std_logic;
			reset_Register: out std_logic;
			modeSin, modeCos, modeTan : in std_logic;
			enFSM : in std_logic;
			outFinal: out std_logic
	);

end component;

component comparator is
	port(	rst, clk: in std_logic;
			Sudut : in std_logic_vector(31 downto 0);
			angle : in std_logic_vector(31 downto 0);
			comparison : out std_logic					-- 0: angle < Sudut. 1: angle >= Sudut
	);
end component;

component subtractor is
	port(	x, y : in std_logic_vector(31 downto 0);
			comparison : in std_logic;
			angle : in std_logic_vector(31 downto 0);
			counter : in std_logic_vector(3 downto 0); --std_logic_vector(3 downto 0);
			x_out, y_out : out std_logic_vector(31 downto 0);
			angle_out : out std_logic_vector(31 downto 0);
			clk : in std_logic;
			tesShifter : out std_logic;
			tesComparison : out std_logic;
			enFSM : out std_logic;
			En_Subtractor : in std_logic
	);
end component;

component regis is
	port(	clk : in std_logic;
			Enable_Reg : in std_logic;
			inputRegister : in std_logic_vector(31 downto 0);
			reset_Reg : in std_logic;
			outputRegister : out std_logic_vector(31 downto 0)  -- GK YAKIN SAMA BUFFER
	);
end component;

component regisX is
	port(	clk : in std_logic;
			Enable_Reg : in std_logic;
			inputRegister : in std_logic_vector(31 downto 0);
			reset_Reg : in std_logic;
			outputRegister : out std_logic_vector(31 downto 0)      -- GK YAKIN SAMA BUFFER
	);
end component;

component regisY is
	port(	clk : in std_logic;
			Enable_Reg : in std_logic;
			inputRegister : in std_logic_vector(31 downto 0);
			reset_Reg : in std_logic;
			outputRegister : out std_logic_vector(31 downto 0)      -- GK YAKIN SAMA BUFFER
	);
end component;

component regisAngle is
	port(	clk : in std_logic;
			Enable_Reg : in std_logic;
			inputRegister : in std_logic_vector(31 downto 0);
			reset_Reg : in std_logic;
			outputRegister : out std_logic_vector(31 downto 0)  -- GK YAKIN SAMA BUFFER
	);
end component;

component counter is
	port(	rst, clk: in std_logic;
			input	: in std_logic;
			counter : buffer std_logic_vector(3 downto 0)
	);
end component;

signal comparison : std_logic;
signal outFinal : std_logic;
signal En_Subtractor : std_logic;
signal En_Reg : std_logic;
signal reset_Register : std_logic;
signal angle : std_logic_vector(31 downto 0);
signal x : std_logic_vector(31 downto 0);
signal y : std_logic_vector(31 downto 0);
signal x_out : std_logic_vector(31 downto 0);
signal y_out : std_logic_vector(31 downto 0);
signal angle_out : std_logic_vector(31 downto 0);
signal outSin : std_logic_vector(31 downto 0);
signal outCos : std_logic_vector(31 downto 0);
signal angkaTemp : std_logic_vector(63 downto 0);  -- 1.3.60
constant k : std_logic_vector(31 downto 0) := "00100110110111010010111100011010";  -- 1.1.30
signal inputCount : std_logic;
signal resetCounter : std_logic;
signal counter2 : std_logic_vector(3 downto 0) := "0000";
signal tesShifter : std_logic;
signal tesComparison : std_logic;
signal enFSM : std_logic := '1';
signal cekAKHIR : std_logic;
<<<<<<< Updated upstream

=======
signal angle_baru : std_logic_vector(31 downto 0);
signal angkaTemp2 : std_logic_vector(31 downto 0);
>>>>>>> Stashed changes
begin

	-- FSM
	TOFSM : fsm port map(rst, clk, inputCount, resetCounter, counter2, comparison, En_Subtractor, En_Reg, reset_Register, modeSin, modeCos, modeTan, enFSM, outFinal);
	-- Datapath
	blokKomparator : comparator port map(rst, clk, Sudut, angle, comparison);
	blokCounter : counter port map(rst, clk, inputCount, counter2);
	blokSubtractor : subtractor port map(x, y, comparison, angle, counter2, x_out, y_out, angle_out, clk, tesShifter, tesComparison, enFSM, En_Subtractor);
	blokRegisX : regisX port map(clk, En_Reg, x_out, reset_Register, x);
	blokRegisY : regisY port map(clk, En_Reg, y_out, reset_Register, y);
	blokRegisAngle : regisAngle port map(clk, En_Reg, angle_out, reset_Register, angle);
	blokOutSin : regis port map(clk, outFinal, x, reset_Register, outSin);
	blokOutCos : regis port map(clk, outFinal, y, reset_Register, outCos);
	
	process(modeSin, modeCos, angkaTemp, outSin, outCos, cekAKHIR)
	begin
	if(modeSin = '1') then  			-- k = 0.60725
		angkaTemp <= outSin * k;		-- 1.1.30 * 1.1.30 = 1.3.60. (not sure, cek lagi konfigurasi fixed-pointnya (?)) : 63 sign, 62 61 60 integer
		
		angka(31) <= angkaTemp(63);		-- karena output sin cos cuman -1 sampe 1, maka 1.1.30
		angka(30) <= angkaTemp(60);
		angka(29 downto 0) <= angkaTemp(59 downto 30);
		cekAKHIR <= '1';
<<<<<<< Updated upstream
=======
		elsif sudut<0 then	
		angle_baru<=not(sudut)+1;
		angkaTemp <= outSin * k;		-- 1.1.30 * 1.1.30 = 1.3.60. (not sure, cek lagi konfigurasi fixed-pointnya (?)) : 63 sign, 62 61 60 integer	
		angkaTemp2(31) <= angkaTemp(63);		-- karena output sin cos cuman -1 sampe 1, maka 1.1.30
		angkaTemp2(30) <= angkaTemp(60);
		angkaTemp2(29 downto 0) <= angkaTemp(59 downto 30);
		angka<=not(angkaTemp2)+1;
		cekAKHIR <= '1';
		end if;
>>>>>>> Stashed changes
	elsif(modeCos = '1') then
		angkaTemp <= outCos * k;
		angka(31) <=  angkaTemp(63);
		angka(30) <= angkaTemp(60);
		angka(29 downto 0) <= angkaTemp(59 downto 30);
		cekAKHIR <= '1';
	else
		cekAKHIR <= '0';
	end if;
	end process;

end tTL_arc;