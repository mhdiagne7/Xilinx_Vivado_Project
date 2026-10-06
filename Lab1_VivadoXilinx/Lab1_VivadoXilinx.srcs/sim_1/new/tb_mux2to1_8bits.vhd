-- Banc d'essai auto-verifiant du multiplexeur 2 vers 1 (8 bits).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mux2to1_8bits is
end tb_mux2to1_8bits;

architecture sim of tb_mux2to1_8bits is
    signal sel : STD_LOGIC := '0';
    signal entree0, entree1, sortie : STD_LOGIC_VECTOR(7 downto 0);
begin
    DUT : entity work.mux2to1_8bits
        port map (sel => sel, entree0 => entree0, entree1 => entree1, sortie => sortie);

    process
        variable erreurs, total : natural := 0;
        procedure essai(s : STD_LOGIC; a, b, attendu : STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            sel <= s; entree0 <= a; entree1 <= b;
            wait for 10 ns;
            total := total + 1;
            if sortie /= attendu then
                erreurs := erreurs + 1;
                report "sortie incorrecte" severity error;
            end if;
        end procedure;
    begin
        essai('0', x"01", x"02", x"01");   -- valeur initiale de LMASK
        essai('1', x"01", x"02", x"02");   -- masque decale
        essai('0', x"80", x"40", x"80");   -- valeur initiale de RMASK
        essai('1', x"80", x"40", x"40");
        essai('0', x"00", x"FF", x"00");
        essai('1', x"00", x"FF", x"FF");
        report "FIN tb_mux2to1_8bits : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        wait;
    end process;
end sim;
