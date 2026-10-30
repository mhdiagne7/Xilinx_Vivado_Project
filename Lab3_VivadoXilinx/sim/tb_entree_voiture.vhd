-- Banc d'essai auto-verifiant de la chaine du capteur :
-- BTNU (avec rebonds) -> debouncer_2 (cours) -> memoire_voiture -> SSCS.
-- Horloge 100 Hz representee par une periode de 10 ns.
--   1. un rebond isole (1 seul echantillon) est ignore ;
--   2. un appui avec rebonds puis stable est detecte et memorise apres
--      le relachement du bouton ;
--   3. le vert de la rue secondaire efface la memoire, meme bouton appuye ;
--   4. apres le vert, un nouvel appui est de nouveau detecte.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_entree_voiture is
end tb_entree_voiture;

architecture test of tb_entree_voiture is

    component debouncer_2
        port ( i_resetBar, i_clock, i_raw : in STD_LOGIC; o_clean : out STD_LOGIC );
    end component;

    component memoire_voiture
        port ( GClock, GResetBar, Bouton, VertSS : in STD_LOGIC; Voiture : out STD_LOGIC );
    end component;

    constant PERIODE : time := 10 ns;

    signal Clk100    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal BTNU      : STD_LOGIC := '0';   -- bouton brut, avec rebonds
    signal Propre    : STD_LOGIC;          -- apres l'anti-rebond
    signal VertSS    : STD_LOGIC := '0';
    signal SSCS      : STD_LOGIC;          -- sortie de la memoire

begin

    DEB : debouncer_2 port map (i_resetBar => GResetBar, i_clock => Clk100,
                                i_raw => BTNU, o_clean => Propre);
    MEM : memoire_voiture port map (GClock => Clk100, GResetBar => GResetBar,
                                    Bouton => Propre, VertSS => VertSS, Voiture => SSCS);

    stimulus : process
        variable erreurs : integer := 0;

        procedure front is
        begin
            wait for PERIODE / 2;
            Clk100 <= '1'; wait for PERIODE / 2;
            Clk100 <= '0';
        end procedure;

        procedure verifier (attendu : STD_LOGIC; msg : string) is
        begin
            if SSCS /= attendu then
                erreurs := erreurs + 1;
                report "ERREUR (" & msg & ")" severity error;
            end if;
        end procedure;

    begin
        wait for PERIODE; GResetBar <= '1';
        front; verifier('0', "apres reset");

        -- 1. Rebond isole : un seul echantillon a 1
        BTNU <= '1'; front; BTNU <= '0'; front; front; front;
        verifier('0', "rebond isole ignore");

        -- 2. Appui avec rebonds, puis stable, puis relache
        BTNU <= '1'; front; BTNU <= '0'; front; BTNU <= '1'; front; BTNU <= '0'; front;
        verifier('0', "rebonds : pas encore de detection");
        BTNU <= '1'; front; front; front; front;
        verifier('1', "appui stable detecte");
        BTNU <= '0'; front; front; front; front; front;
        verifier('1', "bouton relache : la voiture reste memorisee");

        -- 3. La rue secondaire passe au vert : la memoire s'efface
        VertSS <= '1'; front;
        verifier('0', "vert SS : memoire effacee");
        BTNU <= '1'; front; front; front; front;
        verifier('0', "pendant le vert SS : pas de memorisation");
        BTNU <= '0'; front; front;
        VertSS <= '0'; front; front;
        verifier('0', "apres le vert : plus de voiture");

        -- 4. Nouvel appui
        BTNU <= '1'; front; front; front; front; BTNU <= '0'; front; front;
        verifier('1', "nouvelle voiture detectee");

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
