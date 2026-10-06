-- Banc d'essai auto-verifiant du multiplexeur 4 vers 1 (8 bits).
-- Les entrees imitent le chemin de donnees : 0, LMASK, RMASK, LMASK or RMASK.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mux4to1_8bits is
end tb_mux4to1_8bits;

architecture sim of tb_mux4to1_8bits is
    constant E0 : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    constant E1 : STD_LOGIC_VECTOR(7 downto 0) := x"04";
    constant E2 : STD_LOGIC_VECTOR(7 downto 0) := x"20";
    constant E3 : STD_LOGIC_VECTOR(7 downto 0) := x"24";
    signal sel    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal sortie : STD_LOGIC_VECTOR(7 downto 0);
begin
    DUT : entity work.mux4to1_8bits
        port map (sel => sel, entree0 => E0, entree1 => E1, entree2 => E2,
                  entree3 => E3, sortie => sortie);

    process
        variable erreurs, total : natural := 0;
        procedure essai(s : STD_LOGIC_VECTOR(1 downto 0); attendu : STD_LOGIC_VECTOR(7 downto 0)) is
        begin
            sel <= s;
            wait for 10 ns;
            total := total + 1;
            if sortie /= attendu then
                erreurs := erreurs + 1;
                report "selection incorrecte" severity error;
            end if;
        end procedure;
    begin
        essai("00", E0); essai("01", E1); essai("10", E2); essai("11", E3);
        essai("10", E2); essai("00", E0);
        report "FIN tb_mux4to1_8bits : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        wait;
    end process;
end sim;
