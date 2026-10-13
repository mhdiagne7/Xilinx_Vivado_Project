-- Additionneur a propagation de retenue N bits (version generique de rca4).
-- N additionneurs complets en cascade : c(i+1) = retenue sortante de l'etage i.
--   c(0) = cin, c(N) = cout
-- cn1 = c(N-1), la retenue entrant dans le bit de signe (pour le debordement).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rcaN is
    generic ( N : positive := 4 );
    port (
        A    : in  STD_LOGIC_VECTOR(N-1 downto 0);
        B    : in  STD_LOGIC_VECTOR(N-1 downto 0);
        cin  : in  STD_LOGIC;
        S    : out STD_LOGIC_VECTOR(N-1 downto 0);
        cn1  : out STD_LOGIC;
        cout : out STD_LOGIC
    );
end rcaN;

architecture structurel of rcaN is

    component additionneur_complet
        port ( a, b, cin : in STD_LOGIC; s, cout : out STD_LOGIC );
    end component;

    signal c : STD_LOGIC_VECTOR(N downto 0);

begin

    c(0) <= cin;

    ETAGES : for i in 0 to N-1 generate
        FA : additionneur_complet port map (a => A(i), b => B(i), cin => c(i), s => S(i), cout => c(i+1));
    end generate;

    cn1  <= c(N-1);
    cout <= c(N);

end structurel;
