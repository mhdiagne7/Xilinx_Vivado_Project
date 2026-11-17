-- Banc d'essai auto-verifiant du controleur FSM.
-- 1) Une trame complete : A -> B -> (C -> B) x 9 -> C -> A.
-- 2) Test exhaustif : depuis chacun des 3 etats, les 8 combinaisons de
--    (FD, Info, Fin) ; l'etat suivant et les sorties sont compares a la
--    table de transition du pre-lab.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fsm_controleur is
end tb_fsm_controleur;

architecture test of tb_fsm_controleur is

    component fsm_controleur
        port (
            GClock, GResetBar, FD, Info, Fin : in STD_LOGIC;
            RAZ, Charge, Decale : out STD_LOGIC;
            Etat : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;
    constant A : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant B : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant C : STD_LOGIC_VECTOR(1 downto 0) := "11";

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal FD, Fin   : STD_LOGIC := '0';
    signal Info      : STD_LOGIC := '1';
    signal RAZ, Charge, Decale : STD_LOGIC;
    signal Etat      : STD_LOGIC_VECTOR(1 downto 0);
    signal erreurs   : integer := 0;

    -- Table de transition du pre-lab
    function suivant(e : STD_LOGIC_VECTOR(1 downto 0); fd_v, info_v, fin_v : STD_LOGIC)
        return STD_LOGIC_VECTOR is
    begin
        if e = A then
            if fd_v = '1' and info_v = '0' then return B; else return A; end if;
        elsif e = B then
            if fd_v = '1' then return C; else return B; end if;
        else
            if fin_v = '1' then return A; else return B; end if;
        end if;
    end function;

begin

    UUT : fsm_controleur port map (
        GClock => GClock, GResetBar => GResetBar, FD => FD, Info => Info, Fin => Fin,
        RAZ => RAZ, Charge => Charge, Decale => Decale, Etat => Etat
    );

    process
        -- Les entrees sont placees une demi-periode avant le front montant
        procedure front is
        begin
            wait for PERIODE / 2;
            GClock <= '1';
            wait for PERIODE / 2;
            GClock <= '0';
        end procedure;

        procedure verifie_sorties is
            variable raz_att, dec_att : STD_LOGIC;
        begin
            if Etat = A then raz_att := '1'; else raz_att := '0'; end if;
            if Etat = C then dec_att := '1'; else dec_att := '0'; end if;
            if RAZ /= raz_att or Charge /= raz_att or Decale /= dec_att then
                report "ERREUR sorties dans l'etat " & integer'image(to_integer(unsigned(Etat)))
                    severity error;
                erreurs <= erreurs + 1;
            end if;
        end procedure;

        procedure aller_a(e : STD_LOGIC_VECTOR(1 downto 0)) is
        begin
            GResetBar <= '0'; wait for 1 ns; GResetBar <= '1';      -- etat A
            if e /= A then
                FD <= '1'; Info <= '0'; Fin <= '0'; front;           -- A -> B
                if e = C then
                    FD <= '1'; front;                                -- B -> C
                end if;
            end if;
            FD <= '0'; Info <= '1'; Fin <= '0';
        end procedure;

        variable etats  : STD_LOGIC_VECTOR(5 downto 0) := A & B & C;
        variable e, att : STD_LOGIC_VECTOR(1 downto 0);
        variable combo  : STD_LOGIC_VECTOR(2 downto 0);
    begin
        -- 1) Trame complete
        wait for 3 ns;
        GResetBar <= '1';
        verifie_sorties;
        FD <= '1'; Info <= '0'; front;                     -- bit de depart
        FD <= '0'; Info <= '1'; front;                     -- on reste en B
        for bit in 1 to 10 loop
            FD <= '1'; front;                              -- B -> C
            FD <= '0';
            if Etat /= C then
                report "ERREUR : pas en C au bit " & integer'image(bit) severity error;
                erreurs <= erreurs + 1;
            end if;
            verifie_sorties;
            if bit = 10 then Fin <= '1'; end if;
            front;                                         -- C -> B (ou A au bit 10)
            Fin <= '0';
            if (bit < 10 and Etat /= B) or (bit = 10 and Etat /= A) then
                report "ERREUR : mauvaise sortie de C au bit " & integer'image(bit) severity error;
                erreurs <= erreurs + 1;
            end if;
            front;                                         -- attente (FD = 0)
        end loop;

        -- 2) Test exhaustif : 3 etats x 8 combinaisons
        for i in 0 to 2 loop
            e := etats(5 - 2 * i downto 4 - 2 * i);
            for k in 0 to 7 loop
                combo := STD_LOGIC_VECTOR(to_unsigned(k, 3));
                aller_a(e);
                wait for 1 ns;
                if Etat /= e then
                    report "ERREUR : etat de depart non atteint" severity error;
                    erreurs <= erreurs + 1;
                end if;
                verifie_sorties;
                FD <= combo(2); Info <= combo(1); Fin <= combo(0);
                att := suivant(e, combo(2), combo(1), combo(0));
                front;
                wait for 1 ns;
                if Etat /= att then
                    report "ERREUR transition depuis " & integer'image(to_integer(unsigned(e)))
                        & " avec FD Info Fin = " & integer'image(k) severity error;
                    erreurs <= erreurs + 1;
                end if;
                verifie_sorties;
            end loop;
        end loop;

        report "tb_fsm_controleur termine : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
