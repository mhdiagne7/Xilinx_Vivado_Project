-- Banc d'essai auto-verifiant de bascule_D_AS (bascule D, mise a '1'
-- asynchrone, validation d'horloge en). Sert a l'etat initial S0.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_bascule_D_AS is
end tb_bascule_D_AS;

architecture sim of tb_bascule_D_AS is
    signal clk, reset, en, D, Q : STD_LOGIC := '0';
    signal fin : boolean := false;
begin
    clk <= not clk after 5 ns when not fin else '0';

    DUT : entity work.bascule_D_AS
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
        reset <= '1'; D <= '0'; en <= '1';
        wait for 3 ns;                          -- avant tout front d'horloge
        verifier('1', "mise a 1 asynchrone");
        wait until falling_edge(clk); reset <= '0'; en <= '0';
        pas('0', '0'); verifier('1', "en=0 : Q maintenu a 1");
        pas('1', '0'); verifier('0', "en=1, D=0 (sortie de S0)");
        pas('0', '1'); verifier('0', "en=0 : Q maintenu a 0");
        pas('1', '1'); verifier('1', "en=1, D=1");
        pas('1', '0'); verifier('0', "en=1, D=0");
        wait for 2 ns; reset <= '1'; wait for 1 ns;   -- entre deux fronts
        verifier('1', "mise a 1 en cours de cycle");
        report "FIN tb_bascule_D_AS : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;
end sim;
