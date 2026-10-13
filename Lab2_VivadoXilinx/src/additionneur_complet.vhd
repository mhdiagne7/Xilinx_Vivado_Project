-- Additionneur complet 1 bit (additionneur (3,2)), construit avec deux
-- demi-additionneurs et une porte OR (figure 3).
--   DA1 : a + b        -> s1, c1
--   DA2 : s1 + cin     -> s,  c2
--   cout = c1 OR c2
-- Equivalent a : s = a XOR b XOR cin, cout = ab + b.cin + a.cin
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity additionneur_complet is
    port (
        a    : in  STD_LOGIC;
        b    : in  STD_LOGIC;
        cin  : in  STD_LOGIC;
        s    : out STD_LOGIC;
        cout : out STD_LOGIC
    );
end additionneur_complet;

architecture structurel of additionneur_complet is

    component demi_additionneur
        port ( a, b : in STD_LOGIC; s, c : out STD_LOGIC );
    end component;

    signal s1, c1, c2 : STD_LOGIC;

begin

    DA1 : demi_additionneur port map (a => a,  b => b,   s => s1, c => c1);
    DA2 : demi_additionneur port map (a => s1, b => cin, s => s,  c => c2);

    cout <= c1 or c2;

end structurel;
