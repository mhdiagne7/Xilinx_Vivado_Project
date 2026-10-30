-- Banc d'essai auto-verifiant du compteur de vert.
-- Partie 1 : scenario lisible avec Max = 5.
-- Partie 2 : pour chaque Max de 0 a 15, 20 secondes de vert : la valeur doit
--            suivre 0, 1, 2... puis rester bloquee a Max, avec Fini = 1 a Max.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_compteur_vert is
end tb_compteur_vert;

architecture test of tb_compteur_vert is

    component compteur_vert
        port (
            GClock, GResetBar, Load, Vert : in  STD_LOGIC;
            Max    : in  STD_LOGIC_VECTOR(3 downto 0);
            Fini   : out STD_LOGIC;
            Valeur : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal Load      : STD_LOGIC := '1';
    signal Vert      : STD_LOGIC := '0';
    signal Max       : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    signal Fini      : STD_LOGIC;
    signal Valeur    : STD_LOGIC_VECTOR(3 downto 0);
    signal Valeur_dec : integer;

begin

    UUT : compteur_vert port map (
        GClock => GClock, GResetBar => GResetBar, Load => Load, Vert => Vert,
        Max => Max, Fini => Fini, Valeur => Valeur
    );

    Valeur_dec <= to_integer(unsigned(Valeur));

    stimulus : process
        variable erreurs : integer := 0;

        procedure front is
        begin
            wait for PERIODE / 2;
            GClock <= '1'; wait for PERIODE / 2;
            GClock <= '0';
        end procedure;

        procedure verifier (v : integer; f : STD_LOGIC; msg : string) is
        begin
            if Valeur_dec /= v or Fini /= f then
                erreurs := erreurs + 1;
                report "ERREUR (" & msg & ") : valeur " & integer'image(Valeur_dec) &
                       ", attendu " & integer'image(v) severity error;
            end if;
        end procedure;

    begin
        -- Partie 1 : Max = 5
        wait for PERIODE; GResetBar <= '1';
        verifier(0, '0', "apres reset");
        Vert <= '1';
        for k in 1 to 5 loop
            front;
            if k < 5 then verifier(k, '0', "le compteur monte");
            else          verifier(5, '1', "Max atteint : Fini = 1"); end if;
        end loop;
        front; front; verifier(5, '1', "bloque a Max");
        Vert <= '0'; front; verifier(0, '0', "vert eteint : retour a 0");
        Vert <= '1'; front; front; verifier(2, '0', "nouveau vert");
        Load <= '0'; front; front; verifier(2, '0', "Load = 0 : fige");
        Load <= '1'; front; verifier(3, '0', "Load = 1 : repart");
        Vert <= '0'; front;
        Max <= "0000"; wait for 1 ns; verifier(0, '1', "Max = 0 : Fini tout de suite");
        Vert <= '1'; front; verifier(0, '1', "Max = 0 : reste a 0");
        Vert <= '0'; front;
        wait for 2 * PERIODE;

        -- Partie 2 : tous les Max de 0 a 15
        for m in 0 to 15 loop
            Vert <= '0'; Max <= std_logic_vector(to_unsigned(m, 4)); front;
            Vert <= '1';
            for k in 1 to 20 loop
                front;
                if k < m then verifier(k, '0', "partie 2, montee");
                else          verifier(m, '1', "partie 2, bloque a Max"); end if;
            end loop;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
