-- Banc d'essai auto-verifiant du compteur 4 bits.
-- Verifie : RAZ met a 0 ; chaque impulsion Decale ajoute 1 ; sans Decale la
-- valeur est gardee ; Fin = 1 seulement quand la valeur vaut 9 ; RAZ est
-- prioritaire sur Decale ; le compteur fait le tour 15 -> 0.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_compteur4bit is
end tb_compteur4bit;

architecture test of tb_compteur4bit is

    component compteur4bit
        port (
            GClock, GResetBar, RAZ, Decale : in STD_LOGIC;
            Fin : out STD_LOGIC;
            Valeur : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal RAZ       : STD_LOGIC := '0';
    signal Decale    : STD_LOGIC := '0';
    signal Fin       : STD_LOGIC;
    signal Valeur    : STD_LOGIC_VECTOR(3 downto 0);
    signal V_dec     : integer;
    signal erreurs   : integer := 0;

begin

    UUT : compteur4bit port map (GClock => GClock, GResetBar => GResetBar, RAZ => RAZ,
                                 Decale => Decale, Fin => Fin, Valeur => Valeur);
    V_dec <= to_integer(unsigned(Valeur));

    process
        procedure front is
        begin
            wait for PERIODE / 2;
            GClock <= '1';
            wait for PERIODE / 2;
            GClock <= '0';
        end procedure;

        procedure verifie(v : integer; msg : string) is
            variable fin_att : STD_LOGIC;
        begin
            wait for 1 ns;
            if v = 9 then fin_att := '1'; else fin_att := '0'; end if;
            if V_dec /= v or Fin /= fin_att then
                report "ERREUR " & msg & " : valeur " & integer'image(V_dec)
                    & " au lieu de " & integer'image(v) severity error;
                erreurs <= erreurs + 1;
            end if;
        end procedure;
    begin
        wait for 3 ns;
        GResetBar <= '1';
        verifie(0, "apres le reset");
        -- RAZ (comme dans l'etat A)
        RAZ <= '1'; front; front; verifie(0, "RAZ");
        RAZ <= '0';
        -- 12 impulsions Decale, separees par des cycles sans Decale
        for k in 1 to 12 loop
            Decale <= '1'; front;
            Decale <= '0'; verifie(k, "apres Decale");
            front; front; verifie(k, "valeur gardee sans Decale");
        end loop;
        -- RAZ prioritaire sur Decale
        RAZ <= '1'; Decale <= '1'; front;
        RAZ <= '0'; Decale <= '0'; verifie(0, "RAZ prioritaire");
        -- Tour complet 15 -> 0
        for k in 1 to 16 loop
            Decale <= '1'; front;
        end loop;
        Decale <= '0'; verifie(0, "tour complet");

        report "tb_compteur4bit termine : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
