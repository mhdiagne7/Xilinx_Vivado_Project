-- Banc d'essai auto-verifiant du chemin de donnees.
-- Les signaux de commande de chaque etat sont appliques directement, comme
-- le ferait le chemin de commande. Un modele de reference (LMASK, RMASK,
-- DISPLAY avec rotation) calcule l'affichage attendu apres chaque pas.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_datapath is
end tb_datapath;

architecture sim of tb_datapath is
    signal clk, reset, en : STD_LOGIC := '0';
    signal loadDis, loadL, selL, loadR, selR : STD_LOGIC := '0';
    signal selDis : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal DISPLAY_out : STD_LOGIC_VECTOR(7 downto 0);
    signal fin : boolean := false;
begin
    clk <= not clk after 5 ns when not fin else '0';

    DUT : entity work.datapath
        port map (clk => clk, reset => reset, en => en, loadDis => loadDis,
                  selDis => selDis, loadL => loadL, selL => selL,
                  loadR => loadR, selR => selR, DISPLAY_out => DISPLAY_out);

    process
        variable erreurs, total : natural := 0;
        variable disp  : STD_LOGIC_VECTOR(7 downto 0) := x"00";
        variable lmask : STD_LOGIC_VECTOR(7 downto 0) := x"00";
        variable rmask : STD_LOGIC_VECTOR(7 downto 0) := x"00";

        procedure verifier(msg : string) is
        begin
            total := total + 1;
            if DISPLAY_out /= disp then
                erreurs := erreurs + 1;
                report msg & " : DISPLAY incorrect" severity error;
            end if;
        end procedure;

        -- Un cycle d'horloge avec les commandes donnees (loadDis = '1').
        -- Commandes par etat (ASM detaille) :
        --   S0 : loadL loadR, selL=selR=0, selDis=00
        --   S1 : loadL selL loadR selR, selDis=11
        --   S2 : loadL selL, selDis=01
        --   S3 : loadR selR, selDis=10
        --   S4 : selDis=00
        procedure pas(e, lL, sL, lR, sR : STD_LOGIC; sD : STD_LOGIC_VECTOR(1 downto 0)) is
        begin
            wait until falling_edge(clk);
            en <= e; loadDis <= '1';
            loadL <= lL; selL <= sL; loadR <= lR; selR <= sR; selDis <= sD;
            wait until rising_edge(clk); wait for 1 ns;
        end procedure;
    begin
        reset <= '1';
        wait for 3 ns;
        verifier("reset");
        wait until falling_edge(clk); reset <= '0';

        -- S0 : initialisation
        pas('1', '1', '0', '1', '0', "00");
        disp := x"00"; lmask := x"01"; rmask := x"80";
        verifier("S0 : initialisation");

        -- 1) S2 (LEFT seul) pendant 3 pas : seul LMASK avance
        for k in 1 to 3 loop
            pas('1', '1', '1', '0', '0', "01");
            disp := lmask;
            lmask := lmask(6 downto 0) & lmask(7);
            verifier("S2 pas " & integer'image(k));
        end loop;

        -- 2) S3 (RIGHT seul) pendant 3 pas : seul RMASK avance
        for k in 1 to 3 loop
            pas('1', '0', '0', '1', '1', "10");
            disp := rmask;
            rmask := rmask(0) & rmask(7 downto 1);
            verifier("S3 pas " & integer'image(k));
        end loop;

        -- 3) S1 (LEFT et RIGHT) pendant 9 pas : les deux masques tournent
        for k in 1 to 9 loop
            pas('1', '1', '1', '1', '1', "11");
            disp := lmask or rmask;
            lmask := lmask(6 downto 0) & lmask(7);
            rmask := rmask(0) & rmask(7 downto 1);
            verifier("S1 pas " & integer'image(k));
        end loop;

        -- en = 0 : rien ne change
        pas('0', '1', '1', '1', '1', "11");
        verifier("en=0 : affichage maintenu");

        -- S4 : affichage vide, masques figes
        pas('1', '0', '0', '0', '0', "00");
        disp := x"00";
        verifier("S4 : affichage vide");

        -- S2 : reprise au point d'arret
        pas('1', '1', '1', '0', '0', "01");
        disp := lmask;
        lmask := lmask(6 downto 0) & lmask(7);
        verifier("S2 apres S4 : reprise");

        wait for 2 ns; reset <= '1'; wait for 1 ns;
        disp := x"00";
        verifier("reset en cours de cycle");
        report "FIN tb_datapath : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;
end sim;
