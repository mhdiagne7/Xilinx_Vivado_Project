library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity or8bits is
    port (
        entreeA : in  STD_LOGIC_VECTOR(7 downto 0);
        entreeB : in  STD_LOGIC_VECTOR(7 downto 0);
        sortie  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end or8bits;

architecture structurel of or8bits is
begin
    sortie <= entreeA or entreeB;
end structurel;