-- Banc d'essai auto-verifiant de l'afficheur 7 segments (DIV_MAX = 3 pour
-- accelerer : le chiffre change tous les 4 cycles).
-- Pour plusieurs octets (1C, F0, 32, 00, A5), on verifie a chaque cycle que :
--  * un seul des deux chiffres AN1/AN0 est allume, AN7..AN2 et DP eteints ;
--  * le chiffre allume montre la bonne valeur (AN1 = 4 bits du haut,
--    AN0 = 4 bits du bas) ;
--  * les deux chiffres sont bien allumes a tour de role.
-- Les segments attendus sont calcules ici a partir de la table du decodeur
-- (cathodes actives a 0, SEG(6..0) = g f e d c b a).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_afficheur7seg is
end tb_afficheur7seg;

architecture test of tb_afficheur7seg is

    component afficheur7seg
        generic (DIV_MAX : natural);
        port (
            GClock, GResetBar : in STD_LOGIC;
            Octet : in STD_LOGIC_VECTOR(7 downto 0);
            SEG : out STD_LOGIC_VECTOR(6 downto 0);
            DP : out STD_LOGIC;
            AN : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    type table_seg is array (0 to 15) of STD_LOGIC_VECTOR(6 downto 0);
    -- g f e d c b a, actif a 0 : 0 1 2 3 4 5 6 7 8 9 A b C d E F
    constant SEGS : table_seg := (
        "1000000", "1111001", "0100100", "0110000", "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011", "1000110", "0100001", "0000110", "0001110");

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal Octet     : STD_LOGIC_VECTOR(7 downto 0) := x"1C";
    signal SEG       : STD_LOGIC_VECTOR(6 downto 0);
    signal DP        : STD_LOGIC;
    signal AN        : STD_LOGIC_VECTOR(7 downto 0);
    signal erreurs   : integer := 0;
    signal fin_sim   : boolean := false;

begin

    UUT : afficheur7seg generic map (DIV_MAX => 3)
                        port map (GClock => GClock, GResetBar => GResetBar, Octet => Octet,
                                  SEG => SEG, DP => DP, AN => AN);

    GClock <= not GClock after PERIODE / 2 when not fin_sim else '0';

    process
        type liste is array (0 to 4) of STD_LOGIC_VECTOR(7 downto 0);
        constant VALEURS : liste := (x"1C", x"F0", x"32", x"00", x"A5");
        variable vu_gauche, vu_droite : boolean;
        variable haut, bas : integer;
    begin
        wait for 25 ns;
        GResetBar <= '1';
        for v in VALEURS'range loop
            Octet <= VALEURS(v);
            haut := to_integer(unsigned(VALEURS(v)(7 downto 4)));
            bas  := to_integer(unsigned(VALEURS(v)(3 downto 0)));
            vu_gauche := false; vu_droite := false;
            for k in 1 to 20 loop
                wait until falling_edge(GClock);
                if AN(7 downto 2) /= "111111" or DP /= '1' or AN(1) = AN(0) then
                    report "ERREUR : anodes " severity error;
                    erreurs <= erreurs + 1;
                elsif AN(1) = '0' then
                    vu_gauche := true;
                    if SEG /= SEGS(haut) then
                        report "ERREUR : chiffre de gauche" severity error;
                        erreurs <= erreurs + 1;
                    end if;
                else
                    vu_droite := true;
                    if SEG /= SEGS(bas) then
                        report "ERREUR : chiffre de droite" severity error;
                        erreurs <= erreurs + 1;
                    end if;
                end if;
            end loop;
            if not (vu_gauche and vu_droite) then
                report "ERREUR : les deux chiffres ne sont pas affiches a tour de role" severity error;
                erreurs <= erreurs + 1;
            end if;
        end loop;

        report "tb_afficheur7seg termine : " & integer'image(erreurs) & " erreur(s)";
        fin_sim <= true;
        wait;
    end process;

end test;
