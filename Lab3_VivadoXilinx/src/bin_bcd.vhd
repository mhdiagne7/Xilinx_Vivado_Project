-- Conversion binaire (0 a 15) vers deux chiffres decimaux (bonus).
--   v >= 10 : dizaines = 1, unites = v - 10
--   v <  10 : dizaines = 0, unites = v
-- Detection v >= 10 : v3.(v2 + v1)
-- Pour v = 10..15, v - 10 = 0..5 :  u2 = v2.v1 (14, 15), u1 = v2.v1' (12, 13), u0 = v0
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bin_bcd is
    port (
        v        : in  STD_LOGIC_VECTOR(3 downto 0);
        dizaines : out STD_LOGIC_VECTOR(3 downto 0);
        unites   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end bin_bcd;

architecture structurel of bin_bcd is
    signal ge10 : STD_LOGIC;
begin

    ge10 <= v(3) and (v(2) or v(1));

    dizaines <= "000" & ge10;

    unites(3) <= v(3) and not ge10;
    unites(2) <= (v(2) and not ge10) or (v(2) and v(1) and ge10);
    unites(1) <= (v(1) and not ge10) or (v(2) and not v(1) and ge10);
    unites(0) <= v(0);

end structurel;
