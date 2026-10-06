-- Registre 8 bits avec chargement (load) et validation d'horloge (en).
-- Charge D seulement quand en = '1' et load = '1'.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registre8 is
    port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        en     : in  STD_LOGIC;
        load   : in  STD_LOGIC;
        D      : in  STD_LOGIC_VECTOR(7 downto 0);
        Q      : out STD_LOGIC_VECTOR(7 downto 0)
    );
end registre8;

architecture structurel of registre8 is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            Q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' and load = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end structurel;
