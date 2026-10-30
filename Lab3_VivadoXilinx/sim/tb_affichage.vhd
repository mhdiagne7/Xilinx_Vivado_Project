-- Banc d'essai auto-verifiant de l'affichage (bonus).
-- Partie 1 : bin_bcd sur les 16 valeurs (dizaines et unites).
-- Partie 2 : affichage de 12 : AN0 montre « 2 », AN1 montre « 1 », en alternance.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_affichage is
end tb_affichage;

architecture test of tb_affichage is

    component bin_bcd
        port (
            v                : in  STD_LOGIC_VECTOR(3 downto 0);
            dizaines, unites : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component affichage
        port (
            Clk1kHz, GResetBar : in  STD_LOGIC;
            Valeur : in  STD_LOGIC_VECTOR(3 downto 0);
            SEG    : out STD_LOGIC_VECTOR(6 downto 0);
            AN     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal v, diz, uni : STD_LOGIC_VECTOR(3 downto 0);
    signal Clk1kHz     : STD_LOGIC := '0';
    signal GResetBar   : STD_LOGIC := '0';
    signal Valeur      : STD_LOGIC_VECTOR(3 downto 0) := "1100";   -- 12
    signal SEG         : STD_LOGIC_VECTOR(6 downto 0);
    signal AN          : STD_LOGIC_VECTOR(7 downto 0);

    -- Cathodes actives a 0, SEG(0) = a ... SEG(6) = g
    constant SEG_1 : STD_LOGIC_VECTOR(6 downto 0) := "1111001";   -- b, c
    constant SEG_2 : STD_LOGIC_VECTOR(6 downto 0) := "0100100";   -- a, b, d, e, g

begin

    CONV : bin_bcd port map (v => v, dizaines => diz, unites => uni);
    AFF  : affichage port map (Clk1kHz => Clk1kHz, GResetBar => GResetBar, Valeur => Valeur,
                               SEG => SEG, AN => AN);

    stimulus : process
        variable erreurs : integer := 0;
    begin
        -- Partie 1 : conversion des 16 valeurs
        for n in 0 to 15 loop
            v <= std_logic_vector(to_unsigned(n, 4));
            wait for 1 ns;
            if to_integer(unsigned(diz)) /= n / 10 or to_integer(unsigned(uni)) /= n mod 10 then
                erreurs := erreurs + 1;
                report "ERREUR bin_bcd : " & integer'image(n) severity error;
            end if;
        end loop;

        -- Partie 2 : affichage de 12
        wait for 5 ns; GResetBar <= '1'; wait for 1 ns;
        for k in 1 to 4 loop
            if AN = "11111110" then          -- AN0 : unites
                if SEG /= SEG_2 then erreurs := erreurs + 1;
                    report "ERREUR : AN0 devrait afficher 2" severity error; end if;
            elsif AN = "11111101" then       -- AN1 : dizaines
                if SEG /= SEG_1 then erreurs := erreurs + 1;
                    report "ERREUR : AN1 devrait afficher 1" severity error; end if;
            else
                erreurs := erreurs + 1; report "ERREUR : anodes" severity error;
            end if;
            Clk1kHz <= '1'; wait for 5 ns; Clk1kHz <= '0'; wait for 5 ns;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
