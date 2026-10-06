-- Banc d'essai auto-verifiant du registre 8 bits (load + validation en).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_registre8 is
end tb_registre8;

architecture sim of tb_registre8 is
    signal clk, reset, en, load : STD_LOGIC := '0';
    signal D, Q : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal fin : boolean := false;
begin
    clk <= not clk after 5 ns when not fin else '0';

    DUT : entity work.registre8
        port map (clk => clk, reset => reset, en => en, load => load, D => D, Q => Q);

    process
        variable erreurs, total : natural := 0;
        procedure verifier(attendu : STD_LOGIC_VECTOR(7 downto 0); msg : string) is
        begin
            total := total + 1;
            if Q /= attendu then
                erreurs := erreurs + 1;
                report msg & " : Q incorrect" severity error;
            end if;
        end procedure;
        procedure pas(e, l : STD_LOGIC; donnee : STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            wait until falling_edge(clk);
            en <= e; load <= l; D <= donnee;
            wait until rising_edge(clk); wait for 1 ns;
        end procedure;
    begin
        reset <= '1';
        wait for 3 ns;
        verifier(x"00", "reset asynchrone");
        wait until falling_edge(clk); reset <= '0';
        pas('1', '1', x"A5"); verifier(x"A5", "en=1 load=1 : chargement de A5");
        pas('1', '0', x"3C"); verifier(x"A5", "load=0 : maintien");
        pas('0', '1', x"3C"); verifier(x"A5", "en=0 : maintien");
        pas('1', '1', x"3C"); verifier(x"3C", "en=1 load=1 : chargement de 3C");
        pas('1', '1', x"FF"); verifier(x"FF", "chargement de FF");
        wait for 2 ns; reset <= '1'; wait for 1 ns;
        verifier(x"00", "reset en cours de cycle");
        report "FIN tb_registre8 : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;
end sim;
