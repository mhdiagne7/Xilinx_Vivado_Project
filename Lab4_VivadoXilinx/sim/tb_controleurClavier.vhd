-- Banc d'essai auto-verifiant du systeme complet (controleurClavier).
-- Un modele de clavier envoie de vraies trames PS/2 de 11 bits : la donnee
-- change quand l'horloge du clavier est haute et est lue sur le front
-- descendant. Pour une simulation courte, un bit dure 2 us au lieu de
-- 60 a 100 us (toujours bien plus long que la fenetre de 80 ns du filtre).
-- Scenarios :
--  1) apres le reset, l'affichage vaut 00 ;
--  2) appui sur « a » : trame 1C -> BCD1 = 1, BCD2 = C ;
--  3) relachement : trames F0 puis 1C -> F0 s'affiche, puis 1C reste affiche ;
--  4) un parasite de 40 ns sur l'horloge du clavier au repos est ignore ;
--  5) touche « b » (32), puis « Entree » (5A) ;
--  6) pendant une trame, l'affichage garde l'ancien octet.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_controleurClavier is
end tb_controleurClavier;

architecture test of tb_controleurClavier is

    component controleurClavier
        generic (DIV_MAX : natural);
        port (
            HorlogeG, ResetG, HorlogeClavier, InfoClavier : in STD_LOGIC;
            BCD1, BCD2 : out STD_LOGIC_VECTOR(3 downto 0);
            SEG : out STD_LOGIC_VECTOR(6 downto 0);
            DP : out STD_LOGIC;
            AN : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    constant PERIODE  : time := 10 ns;     -- horloge globale 100 MHz
    constant DEMI_BIT : time := 1 us;      -- horloge du clavier : 500 kHz en simulation

    signal HorlogeG       : STD_LOGIC := '0';
    signal ResetG         : STD_LOGIC := '0';
    signal HorlogeClavier : STD_LOGIC := '1';
    signal InfoClavier    : STD_LOGIC := '1';
    signal BCD1, BCD2     : STD_LOGIC_VECTOR(3 downto 0);
    signal SEG            : STD_LOGIC_VECTOR(6 downto 0);
    signal DP             : STD_LOGIC;
    signal AN             : STD_LOGIC_VECTOR(7 downto 0);
    signal Affiche        : STD_LOGIC_VECTOR(7 downto 0);
    signal erreurs        : integer := 0;
    signal fin_sim        : boolean := false;

begin

    UUT : controleurClavier generic map (DIV_MAX => 3)
        port map (HorlogeG => HorlogeG, ResetG => ResetG, HorlogeClavier => HorlogeClavier,
                  InfoClavier => InfoClavier, BCD1 => BCD1, BCD2 => BCD2, SEG => SEG, DP => DP, AN => AN);

    HorlogeG <= not HorlogeG after PERIODE / 2 when not fin_sim else '0';
    Affiche  <= BCD1 & BCD2;

    process
        -- Modele du clavier : envoie une trame de 11 bits
        procedure envoie(octet : STD_LOGIC_VECTOR(7 downto 0)) is
            variable trame : STD_LOGIC_VECTOR(10 downto 0);
            variable p     : STD_LOGIC := '1';
        begin
            for i in 0 to 7 loop
                p := p xor octet(i);                 -- parite impaire
            end loop;
            trame := '1' & p & octet & '0';          -- arret, parite, donnees, depart
            for i in 0 to 10 loop
                InfoClavier <= trame(i);             -- donnee posee, horloge haute
                wait for DEMI_BIT;
                HorlogeClavier <= '0';               -- front descendant : bit lu
                wait for DEMI_BIT;
                HorlogeClavier <= '1';
            end loop;
            InfoClavier <= '1';
            wait for 5 us;                           -- ligne au repos entre deux trames
        end procedure;

        procedure verifie(attendu : STD_LOGIC_VECTOR(7 downto 0); msg : string) is
        begin
            if Affiche /= attendu then
                report "ERREUR : " & msg severity error;
                erreurs <= erreurs + 1;
            end if;
        end procedure;
    begin
        wait for 25 ns;
        ResetG <= '1';
        wait for 3 us;
        verifie(x"00", "affichage different de 00 apres le reset");

        envoie(x"1C");                               -- appui sur « a »
        verifie(x"1C", "appui sur a : 1C attendu");
        envoie(x"F0");                               -- relachement : F0 ...
        verifie(x"F0", "relachement : F0 attendu");
        envoie(x"1C");                               -- ... puis 1C
        verifie(x"1C", "relachement : 1C attendu a la fin");

        HorlogeClavier <= '0'; wait for 40 ns; HorlogeClavier <= '1';   -- parasite
        wait for 3 us;
        verifie(x"1C", "le parasite a modifie l'affichage");

        envoie(x"32");                               -- touche « b »
        verifie(x"32", "touche b : 32 attendu");

        -- Pendant une trame, l'affichage garde l'ancien octet : on lance la
        -- trame 5A et on verifie au milieu (apres 6 bits) que 32 est garde.
        InfoClavier <= '0';
        for i in 0 to 5 loop
            wait for DEMI_BIT; HorlogeClavier <= '0';
            wait for DEMI_BIT; HorlogeClavier <= '1';
            InfoClavier <= '0';
        end loop;
        verifie(x"32", "l'affichage a change pendant une trame");
        -- On remet le systeme a zero (trame incomplete) puis on envoie 5A
        ResetG <= '0'; wait for 30 ns; ResetG <= '1';
        wait for 3 us;
        verifie(x"00", "reset : 00 attendu");
        envoie(x"5A");                               -- touche « Entree »
        verifie(x"5A", "touche Entree : 5A attendu");

        report "tb_controleurClavier termine : " & integer'image(erreurs) & " erreur(s)";
        fin_sim <= true;
        wait;
    end process;

end test;
