-- Diviseur d'horloge a base de compteur.
-- Emet une impulsion "tick" d'un seul cycle de clk tous les N cycles.
-- N = f_clk / f_enable : 100_000_000 pour ~1 Hz sur la Nexys A7 (100 MHz).
-- Le banc d'essai remplace N par une petite valeur (generic).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity diviseur_horloge is
    generic (
        N : positive := 100_000_000
    );
    port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        tick  : out STD_LOGIC
    );
end diviseur_horloge;

architecture structurel of diviseur_horloge is
    signal compte : natural range 0 to N - 1;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            compte <= 0;
            tick   <= '0';
        elsif rising_edge(clk) then
            if compte = N - 1 then
                compte <= 0;
                tick   <= '1';
            else
                compte <= compte + 1;
                tick   <= '0';
            end if;
        end if;
    end process;
end structurel;
