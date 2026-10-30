-- Banc d'essai auto-verifiant du systeme complet (sans diviseur ni affichage).
-- Horloges : 1 Hz represente par 1000 ns (une "seconde"), 100 Hz par 10 ns,
-- soit le meme rapport (x100) que sur la carte.
-- MSC = 3 et SSC = 2 : vert MS de 4 s minimum, jaune MS 3 s, vert SS 3 s,
-- jaune SS 2 s.
-- Scenarios (enonce section 5.5) :
--   1. pas de voiture : MS reste vert, compteur bloque a MSC
--   2. voiture apres le temps de vert (appui court de 50 ms) : cycle complet
--   3. voiture avant la fin du vert : on attend quand meme MSC
--   4. voiture toujours la : le vert SS se termine quand meme apres SSC
--   5. LOAD_FSM = 0 : tout est fige
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_systeme_feux is
end tb_systeme_feux;

architecture test of tb_systeme_feux is

    component systeme_feux
        port (
            Clk1Hz, Clk100Hz, GResetBar, Load, Capteur : in STD_LOGIC;
            MSC, SSC   : in  STD_LOGIC_VECTOR(3 downto 0);
            MSTL, SSTL : out STD_LOGIC_VECTOR(2 downto 0);
            Compteur   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    constant SECONDE : time := 1000 ns;

    signal Clk1Hz, Clk100Hz : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal Load      : STD_LOGIC := '1';
    signal Capteur   : STD_LOGIC := '0';
    signal MSC       : STD_LOGIC_VECTOR(3 downto 0) := "0011";
    signal SSC       : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    signal MSTL, SSTL : STD_LOGIC_VECTOR(2 downto 0);
    signal Compteur  : STD_LOGIC_VECTOR(3 downto 0);
    signal fin       : boolean := false;

    -- Etat lisible dans la forme d'onde : A, B, C, D
    signal etat : character;

begin

    UUT : systeme_feux port map (
        Clk1Hz => Clk1Hz, Clk100Hz => Clk100Hz, GResetBar => GResetBar, Load => Load,
        Capteur => Capteur, MSC => MSC, SSC => SSC, MSTL => MSTL, SSTL => SSTL,
        Compteur => Compteur
    );

    Clk100Hz <= not Clk100Hz after 5 ns when not fin else '0';
    Clk1Hz   <= not Clk1Hz after SECONDE / 2 when not fin else '0';

    etat <= 'A' when MSTL = "001" and SSTL = "100" else
            'B' when MSTL = "010" and SSTL = "100" else
            'C' when MSTL = "100" and SSTL = "001" else
            'D' when MSTL = "100" and SSTL = "010" else '?';

    stimulus : process
        variable erreurs : integer := 0;

        procedure verifier (attendu : character; msg : string) is
        begin
            if etat /= attendu then
                erreurs := erreurs + 1;
                report "ERREUR (" & msg & ") : etat " & etat & ", attendu " & attendu severity error;
            end if;
        end procedure;

        -- Compte combien de secondes la machine reste dans l'etat courant
        procedure duree (attendu : character; secondes : integer; msg : string) is
            variable n : integer := 0;
        begin
            verifier(attendu, msg);
            while etat = attendu and n < 30 loop
                wait until rising_edge(Clk1Hz); wait for 1 ns;
                n := n + 1;
            end loop;
            if n /= secondes then
                erreurs := erreurs + 1;
                report "ERREUR (" & msg & ") : " & integer'image(n) & " s au lieu de " &
                       integer'image(secondes) & " s" severity error;
            end if;
        end procedure;

        procedure appui_court is   -- 50 ms (5 periodes de 100 Hz)
        begin
            Capteur <= '1'; wait for 50 ns; Capteur <= '0';
        end procedure;

    begin
        wait for 200 ns; GResetBar <= '1';
        wait until rising_edge(Clk1Hz); wait for 1 ns;     -- aligne sur une seconde

        -- 1. Pas de voiture : MS reste vert, le compteur reste a MSC
        verifier('A', "apres reset");
        for k in 1 to 10 loop
            wait until rising_edge(Clk1Hz); wait for 1 ns;
        end loop;
        verifier('A', "10 s sans voiture : toujours MS vert");
        if to_integer(unsigned(Compteur)) /= 3 then
            erreurs := erreurs + 1; report "ERREUR : compteur pas bloque a MSC" severity error;
        end if;

        -- 2. Une voiture arrive (appui court) : cycle complet
        appui_court;
        wait until rising_edge(Clk1Hz); wait for 1 ns;
        duree('B', 3, "jaune MS");
        duree('C', 3, "vert SS (SSC + 1)");
        duree('D', 2, "jaune SS");
        verifier('A', "retour MS vert");

        -- 3. Voiture des le debut du vert : MS reste vert MSC + 1 = 4 s
        appui_court;
        duree('A', 4, "vert MS avec voiture deja la");
        duree('B', 3, "jaune MS (2)");

        -- 4. Voiture toujours presente : le vert SS se termine quand meme
        Capteur <= '1';
        duree('C', 3, "vert SS meme avec voiture");
        duree('D', 2, "jaune SS (2)");
        Capteur <= '0';

        -- 5. LOAD_FSM = 0 : la machine reste dans son etat
        verifier('A', "avant Load = 0");
        Load <= '0'; appui_court;
        for k in 1 to 8 loop
            wait until rising_edge(Clk1Hz); wait for 1 ns;
        end loop;
        verifier('A', "Load = 0 : fige");
        Load <= '1';
        wait until rising_edge(Clk1Hz); wait for 1 ns;
        duree('A', 3, "Load = 1 : reprise du compte jusqu'a MSC");
        verifier('B', "voiture memorisee pendant Load = 0");

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        fin <= true;
        wait;
    end process;

end test;
