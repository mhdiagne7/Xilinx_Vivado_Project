-- Multiplexeur 2 vers 1 sur N bits, en portes logiques.
--   sel = '0' : Y = D0
--   sel = '1' : Y = D1
-- Pour chaque bit : Y(i) = D0(i).sel' + D1(i).sel
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2N is
    generic ( N : positive := 4 );
    port (
        sel : in  STD_LOGIC;
        D0  : in  STD_LOGIC_VECTOR(N-1 downto 0);
        D1  : in  STD_LOGIC_VECTOR(N-1 downto 0);
        Y   : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
end mux2N;

architecture structurel of mux2N is
begin

    BITS : for i in 0 to N-1 generate
        Y(i) <= (D0(i) and not sel) or (D1(i) and sel);
    end generate;

end structurel;
