-- Banc d'essai auto-verifiant de la minuterie des jaunes.
-- Jaune MS : T = 0, 1, 2 et MTE = 1 a T = 2 (3 s de jaune avec la FSM).
-- Jaune SS : T = 0, 1 et STE = 1 a T = 1 (2 s de jaune avec la FSM).
-- Verifie aussi la remise a 0 hors jaune, que MTE/STE ne s'allument que
-- pendant le bon jaune, et Load = 0.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_minuterie_jaunes is
end tb_minuterie_jaunes;

architecture test of tb_minuterie_jaunes is

    component minuterie_jaunes
        port (
            GClock, GResetBar, Load, JauneMS, JauneSS : in STD_LOGIC;
            MTE, STE : out STD_LOGIC;
            Valeur   : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal Load      : STD_LOGIC := '1';
    signal JauneMS, JauneSS : STD_LOGIC := '0';
    signal MTE, STE  : STD_LOGIC;
    signal Valeur    : STD_LOGIC_VECTOR(1 downto 0);
    signal T_dec     : integer;

begin

    UUT : minuterie_jaunes port map (
        GClock => GClock, GResetBar => GResetBar, Load => Load,
        JauneMS => JauneMS, JauneSS => JauneSS, MTE => MTE, STE => STE, Valeur => Valeur
    );

    T_dec <= to_integer(unsigned(Valeur));

    stimulus : process
        variable erreurs : integer := 0;

        procedure front is
        begin
            wait for PERIODE / 2;
            GClock <= '1'; wait for PERIODE / 2;
            GClock <= '0';
        end procedure;

        procedure verifier (t : integer; m, s : STD_LOGIC; msg : string) is
        begin
            wait for 1 ns;
            if T_dec /= t or MTE /= m or STE /= s then
                erreurs := erreurs + 1;
                report "ERREUR (" & msg & ") : T = " & integer'image(T_dec) severity error;
            end if;
        end procedure;

    begin
        wait for PERIODE; GResetBar <= '1';
        verifier(0, '0', '0', "apres reset");

        -- Jaune de la rue principale
        JauneMS <= '1';
        verifier(0, '0', '0', "debut jaune MS");
        front; verifier(1, '0', '0', "jaune MS, 1 s");
        front; verifier(2, '1', '0', "jaune MS, 2 s : MTE");
        JauneMS <= '0';
        verifier(2, '0', '0', "plus de jaune : MTE retombe");
        front; verifier(0, '0', '0', "remise a 0 hors jaune");

        -- Jaune de la rue secondaire
        JauneSS <= '1';
        verifier(0, '0', '0', "debut jaune SS");
        front; verifier(1, '0', '1', "jaune SS, 1 s : STE");
        front; verifier(2, '0', '0', "T = 2 pendant le jaune SS : pas de MTE");
        JauneSS <= '0'; front; verifier(0, '0', '0', "remise a 0");

        -- Load = 0 fige la minuterie
        JauneMS <= '1'; front; verifier(1, '0', '0', "jaune MS, 1 s");
        Load <= '0'; front; front; verifier(1, '0', '0', "Load = 0 : fige");
        Load <= '1'; front; verifier(2, '1', '0', "Load = 1 : repart, MTE");
        JauneMS <= '0'; front;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
