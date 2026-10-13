-- Additionneur a propagation de retenue 4 bits (figure 4).
-- Quatre additionneurs complets en cascade : la retenue sortante de
-- l'etage i devient la retenue entrante de l'etage i+1.
--   c(0) = cin, c(4) = cout
-- c3 (retenue entrant dans le bit de signe) est sortie pour le calcul
-- du debordement dans addsub4.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rca4 is
    port (
        A    : in  STD_LOGIC_VECTOR(3 downto 0);
        B    : in  STD_LOGIC_VECTOR(3 downto 0);
        cin  : in  STD_LOGIC;
        S    : out STD_LOGIC_VECTOR(3 downto 0);
        c3   : out STD_LOGIC;
        cout : out STD_LOGIC
    );
end rca4;

architecture structurel of rca4 is

    component additionneur_complet
        port ( a, b, cin : in STD_LOGIC; s, cout : out STD_LOGIC );
    end component;

    signal c : STD_LOGIC_VECTOR(4 downto 0);

begin

    c(0) <= cin;

    FA0 : additionneur_complet port map (a => A(0), b => B(0), cin => c(0), s => S(0), cout => c(1));
    FA1 : additionneur_complet port map (a => A(1), b => B(1), cin => c(1), s => S(1), cout => c(2));
    FA2 : additionneur_complet port map (a => A(2), b => B(2), cin => c(2), s => S(2), cout => c(3));
    FA3 : additionneur_complet port map (a => A(3), b => B(3), cin => c(3), s => S(3), cout => c(4));

    c3   <= c(3);
    cout <= c(4);

end structurel;
