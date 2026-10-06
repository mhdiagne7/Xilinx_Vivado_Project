library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1_8bits is
    port (
        sel    : in  STD_LOGIC;
        entree0: in  STD_LOGIC_VECTOR(7 downto 0);
        entree1: in  STD_LOGIC_VECTOR(7 downto 0);
        sortie : out STD_LOGIC_VECTOR(7 downto 0)
    );
end mux2to1_8bits;

architecture structurel of mux2to1_8bits is
begin
    sortie <= entree0 when sel = '0' else entree1;
end structurel;