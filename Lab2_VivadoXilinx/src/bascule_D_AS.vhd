-- Bascule D avec mise a 1 asynchrone (module atomique).
-- Sert a l'etat initial S0 de la commande one-hot : GReset y place le '1'.
--   reset = '1'          : Q <= '1' immediatement
--   front montant de clk : Q <= D, seulement si en = '1'
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bascule_D_AS is
    port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        en    : in  STD_LOGIC;
        D     : in  STD_LOGIC;
        Q     : out STD_LOGIC
    );
end bascule_D_AS;

architecture structurel of bascule_D_AS is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            Q <= '1';
        elsif rising_edge(clk) then
            if en = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end structurel;
