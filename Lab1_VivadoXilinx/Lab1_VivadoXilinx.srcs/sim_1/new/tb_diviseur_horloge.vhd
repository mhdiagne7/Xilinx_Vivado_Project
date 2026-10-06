-- Banc d'essai auto-verifiant du diviseur d'horloge.
-- N reduit a 5 : tick doit valoir '1' pendant exactement 1 cycle sur 5.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_diviseur_horloge is
end tb_diviseur_horloge;

architecture sim of tb_diviseur_horloge is
    constant N : positive := 5;
    signal clk, reset, tick : STD_LOGIC := '0';
    signal fin : boolean := false;
begin
    clk <= not clk after 5 ns when not fin else '0';

    DUT : entity work.diviseur_horloge
        generic map (N => N)
        port map (clk => clk, reset => reset, tick => tick);

    process
        variable erreurs, total, nb_ticks : natural := 0;
        procedure verifier(ok : boolean; msg : string) is
        begin
            total := total + 1;
            if not ok then
                erreurs := erreurs + 1;
                report msg severity error;
            end if;
        end procedure;
    begin
        reset <= '1';
        wait for 23 ns;
        verifier(tick = '0', "tick doit valoir 0 pendant le reset");
        reset <= '0';
        -- Se synchroniser sur la premiere impulsion, puis verifier 4 periodes :
        -- exactement une impulsion d'un cycle tous les N cycles.
        wait until tick = '1'; wait for 1 ns;
        for p in 1 to 4 loop
            nb_ticks := 0;
            for c in 1 to N loop
                wait until rising_edge(clk); wait for 1 ns;
                if tick = '1' then nb_ticks := nb_ticks + 1; end if;
            end loop;
            verifier(nb_ticks = 1, "periode " & integer'image(p) & " : une seule impulsion attendue");
            verifier(tick = '1', "periode " & integer'image(p) & " : impulsion tous les N cycles");
        end loop;
        reset <= '1'; wait for 1 ns;
        verifier(tick = '0', "reset : tick remis a 0");
        report "FIN tb_diviseur_horloge : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;
end sim;
