library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4to1_8bits is
    port (
        sel    : in  STD_LOGIC_VECTOR(1 downto 0);
        entree0: in  STD_LOGIC_VECTOR(7 downto 0);
        entree1: in  STD_LOGIC_VECTOR(7 downto 0);
        entree2: in  STD_LOGIC_VECTOR(7 downto 0);
        entree3: in  STD_LOGIC_VECTOR(7 downto 0);
        sortie : out STD_LOGIC_VECTOR(7 downto 0)
    );
end mux4to1_8bits;

architecture structurel of mux4to1_8bits is
begin
    process(sel, entree0, entree1, entree2, entree3)
    begin
        case sel is
            when "00"   => sortie <= entree0;
            when "01"   => sortie <= entree1;
            when "10"   => sortie <= entree2;
            when others => sortie <= entree3;
        end case;
    end process;
end structurel;