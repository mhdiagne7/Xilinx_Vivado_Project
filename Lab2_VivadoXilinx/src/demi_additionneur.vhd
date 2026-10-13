-- Demi-additionneur 1 bit (additionneur (2,2)), tableau 1 / figure 1.
--   s = a XOR b
--   c = a AND b
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demi_additionneur is
    port (
        a : in  STD_LOGIC;
        b : in  STD_LOGIC;
        s : out STD_LOGIC;
        c : out STD_LOGIC
    );
end demi_additionneur;

architecture structurel of demi_additionneur is
begin
    s <= a xor b;
    c <= a and b;
end structurel;
