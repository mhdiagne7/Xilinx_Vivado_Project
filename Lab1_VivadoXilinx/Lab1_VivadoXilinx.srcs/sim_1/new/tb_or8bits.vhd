-- Banc d'essai auto-verifiant du OU logique 8 bits.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_or8bits is
end tb_or8bits;

architecture sim of tb_or8bits is
    signal entreeA, entreeB, sortie : STD_LOGIC_VECTOR(7 downto 0);
begin
    DUT : entity work.or8bits
        port map (entreeA => entreeA, entreeB => entreeB, sortie => sortie);

    process
        variable erreurs, total : natural := 0;
        procedure essai(a, b, attendu : STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            entreeA <= a; entreeB <= b;
            wait for 10 ns;
            total := total + 1;
            if sortie /= attendu then
                erreurs := erreurs + 1;
                report "OU incorrect" severity error;
            end if;
        end procedure;
    begin
        essai(x"00", x"00", x"00");
        essai(x"01", x"80", x"81");   -- LMASK et RMASK initiaux
        essai(x"08", x"10", x"18");   -- les deux lumieres se rapprochent
        essai(x"10", x"10", x"10");   -- meme position
        essai(x"F0", x"0F", x"FF");
        essai(x"AA", x"00", x"AA");
        report "FIN tb_or8bits : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        wait;
    end process;
end sim;
