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
			count: out integer;
			comparison: in std_logic; -- 0: angle< Sudut. 1: angle>=Sudut.
			en_Subtractor: out std_logic;
			en_Register: out std_logic;
			reset_Register: out std_logic;
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
			count : in integer; 						--std_logic_vector(3 downto 0);
			x_out, y_out : out std_logic_vector(31 downto 0);
			angle_out : out std_logic_vector(31 downto 0);
			En_Subtractor : in std_logic
	);
end component;

component regis is
	port(	clk : in std_logic;
			Enable_Reg : in std_logic;
			inputRegister : in std_logic_vector(31 downto 0);
			reset_Reg : in std_logic;
			outputRegister : buffer std_logic_vector(31 downto 0)      -- GK YAKIN SAMA BUFFER
	);
end component;

component regisAngle is
	port(	clk : in std_logic;
			Enable_Reg : in std_logic;
			inputRegister : in std_logic_vector(31 downto 0);
			reset_Reg : in std_logic;
			outputRegister : buffer std_logic_vector(31 downto 0)  -- GK YAKIN SAMA BUFFER
	);
end component;

signal comparison : std_logic;
signal count : integer:=0;
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

begin

	-- FSM
	TOFSM : fsm port map(rst, clk, count, comparison, En_Subtractor, En_Reg, reset_Register, outFinal);
	-- Datapath
	blokKomparator : comparator port map(rst, clk, Sudut, angle, comparison);
	blokSubtractor : subtractor port map(x, y, comparison, angle, count, x_out, y_out, angle_out, En_Subtractor);
	blokRegisX : regis port map(clk, En_Reg, x_out, reset_Register, x);
	blokRegisY : regis port map(clk, En_Reg, y_out, reset_Register, y);
	blokRegisAngle : regisAngle port map(clk, En_Reg, angle_out, reset_Register, angle);
	blokOutSin : regis port map(clk, outFinal, x, reset_Register, outSin);
	blokOutCos : regis port map(clk, outFinal, y, reset_Register, outCos);
	
	process(modeSin, modeCos, angkaTemp)
	begin
	if(modeSin = '1') then  			-- k = 0.60725
		angkaTemp <= outSin * k;		-- 1.1.30 * 1.1.30 = 1.3.60. (not sure, cek lagi konfigurasi fixed-pointnya (?)) : 63 sign, 62 61 60 integer
		angka(31) <= angkaTemp(63);		-- karena output sin cos cuman -1 sampe 1, maka 1.1.30
		angka(30) <= angkaTemp(60);
		angka(29 downto 0) <= angkaTemp(59 downto 30);
	elsif(modeCos = '1') then
		angkaTemp <= outCos * k;
		angka(31) <=  angkaTemp(63);
		angka(30) <= angkaTemp(60);
		angka(29 downto 0) <= angkaTemp(59 downto 30);
	end if;
	end process;

end tTL_arc;