-- Banc d'essai auto-verifiant de bascule_D_AR (bascule D, reset asynchrone
-- a '0', validation d'horloge en). Les entrees changent sur le front
-- descendant, la sortie est verifiee 1 ns apres le front montant.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_bascule_D_AR is
end tb_bascule_D_AR;

architecture sim of tb_bascule_D_AR is
    signal clk, reset, en, D, Q : STD_LOGIC := '0';
    signal fin : boolean := false;
begin
    clk <= not clk after 5 ns when not fin else '0';

    DUT : entity work.bascule_D_AR
        port map (clk => clk, reset => reset, en => en, D => D, Q => Q);

    process
        variable erreurs, total : natural := 0;
        procedure verifier(attendu : STD_LOGIC; msg : string) is
        begin
            total := total + 1;
            if Q /= attendu then
                erreurs := erreurs + 1;
                report msg & " : Q incorrect" severity error;
            end if;
        end procedure;
        procedure pas(e, donnee : STD_LOGIC) is
        begin
            wait until falling_edge(clk);
            en <= e; D <= donnee;
            wait until rising_edge(clk); wait for 1 ns;
        end procedure;
    begin
        reset <= '1'; D <= '1'; en <= '1';
        wait for 3 ns;                          -- avant tout front d'horloge
        verifier('0', "reset asynchrone");
        wait until falling_edge(clk); reset <= '0'; en <= '0';
        pas('1', '1'); verifier('1', "en=1, D=1");
        pas('0', '0'); verifier('1', "en=0 : Q maintenu");
        pas('1', '0'); verifier('0', "en=1, D=0");
        pas('1', '1'); verifier('1', "en=1, D=1 (2)");
        wait for 2 ns; reset <= '1'; wait for 1 ns;   -- entre deux fronts
        verifier('0', "reset en cours de cycle");
        report "FIN tb_bascule_D_AR : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;
end sim;
