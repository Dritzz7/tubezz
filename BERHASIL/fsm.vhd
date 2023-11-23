library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fsm is
    port(
        clk, rst : in std_logic;
        enMain : out std_logic;
        rstCounter : out std_logic;
        counterOut : in std_logic_vector(3 downto 0);
        enCounter : out std_logic
    );
end entity;

architecture fsm_arc of fsm is
    type state is (s0, s1, s2);
    signal currentState, nextState : state := s2;
    signal enMain2, enCounter2 : std_logic;

begin
    process(rst, clk)
    begin
        if (rst = '1') then
            currentState <= s0;
        elsif (clk'EVENT and clk = '1') then
            currentState <= nextState;
            enMain <= enMain2;
            enCounter <= enCounter2;
        end if;
    end process;

    process(currentState, counterOut)
    begin
        case currentState is
            when s0 =>
                enMain2 <= '0';
                enCounter2 <= '0';
                
                if counterOut = "1101" then
                    rstCounter <= '1';
                    nextState <= s0;
                else
					rstCounter <= '0';
                    nextState <= s1;
                end if;
            when s1 =>
                if counterOut = "1101" then
                    rstCounter <= '1';
                    enMain2 <= '0';
                    enCounter2 <= '0';
                    nextState <= s0;
                else
                    rstCounter <= '0';
                    enMain2 <= '0';
                    enCounter2 <= '1';
                    nextState <= s2;
                end if;
            when s2 =>
                if counterOut = "1101" then
                    rstCounter <= '1';
                    enMain2 <= '0';
                    enCounter2 <= '0';
                    nextState <= s0;
                else
                    rstCounter <= '0';
                    enMain2 <= '1';
                    enCounter2 <= '0';
                    nextState <= s1;
                end if;
        end case;
    end process;

end fsm_arc;
