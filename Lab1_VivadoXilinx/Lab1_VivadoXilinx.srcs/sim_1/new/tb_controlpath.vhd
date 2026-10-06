-- Banc d'essai auto-verifiant du chemin de commande (one-hot).
-- Pour chaque combinaison LEFT/RIGHT, une impulsion en fait avancer la
-- machine a etats; les signaux de commande sont compares a ceux attendus
-- pour l'etat vise (diagramme ASM detaille).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_controlpath is
end tb_controlpath;

architecture sim of tb_controlpath is
    signal clk, reset, en, LEFT_sw, RIGHT_sw : STD_LOGIC := '0';
    signal loadDis, loadL, selL, loadR, selR : STD_LOGIC;
    signal selDis : STD_LOGIC_VECTOR(1 downto 0);
    signal fin : boolean := false;

    -- Signaux de commande attendus : loadL, selL, loadR, selR, selDis(1), selDis(0)
    subtype cmd_t is STD_LOGIC_VECTOR(5 downto 0);
    constant CMD_S0 : cmd_t := "101000";   -- initialisation
    constant CMD_S1 : cmd_t := "111111";   -- LEFT et RIGHT
    constant CMD_S2 : cmd_t := "110001";   -- LEFT seul
    constant CMD_S3 : cmd_t := "001110";   -- RIGHT seul
    constant CMD_S4 : cmd_t := "000000";   -- aucun
begin
    clk <= not clk after 5 ns when not fin else '0';

    DUT : entity work.controlpath
        port map (clk => clk, reset => reset, en => en, LEFT_sw => LEFT_sw,
                  RIGHT_sw => RIGHT_sw, loadDis => loadDis, selDis => selDis,
                  loadL => loadL, selL => selL, loadR => loadR, selR => selR);

    process
        variable erreurs, total : natural := 0;
        procedure verifier(attendu : cmd_t; msg : string) is
        begin
            total := total + 1;
            if (loadL & selL & loadR & selR & selDis) /= attendu or loadDis /= '1' then
                erreurs := erreurs + 1;
                report msg & " : signaux de commande incorrects" severity error;
            end if;
        end procedure;
        -- Un cycle d'horloge avec les interrupteurs l, r et la validation e
        procedure pas(l, r, e : STD_LOGIC) is
        begin
            wait until falling_edge(clk);
            LEFT_sw <= l; RIGHT_sw <= r; en <= e;
            wait until rising_edge(clk); wait for 1 ns;
        end procedure;
    begin
        reset <= '1';
        wait for 3 ns;
        verifier(CMD_S0, "reset -> S0");
        wait until falling_edge(clk); reset <= '0';
        pas('1', '0', '0'); verifier(CMD_S0, "en=0 : reste en S0");
        -- 1) LEFT seul
        pas('1', '0', '1'); verifier(CMD_S2, "LEFT -> S2");
        pas('1', '0', '1'); verifier(CMD_S2, "LEFT -> reste en S2");
        -- 2) RIGHT seul
        pas('0', '1', '1'); verifier(CMD_S3, "RIGHT -> S3");
        pas('0', '1', '1'); verifier(CMD_S3, "RIGHT -> reste en S3");
        -- 3) LEFT et RIGHT
        pas('1', '1', '1'); verifier(CMD_S1, "LEFT et RIGHT -> S1");
        pas('1', '1', '1'); verifier(CMD_S1, "LEFT et RIGHT -> reste en S1");
        -- en = 0 : l'etat est maintenu malgre le changement des interrupteurs
        pas('1', '0', '0'); verifier(CMD_S1, "en=0 : reste en S1");
        wait for 2 ns; reset <= '1'; wait for 1 ns;
        verifier(CMD_S0, "reset en cours de cycle -> S0");
        report "FIN tb_controlpath : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;
end sim;
