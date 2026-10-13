-- Unite d'addition/soustraction N bits en complement a 2 (version generique
-- de addsub4, figure 6).
--   AddSub = '0' : S = A + B
--   AddSub = '1' : S = A + not B + 1 = A - B
-- Signaux d'etat :
--   CarryOut    = c(N), retenue sortant du dernier additionneur complet
--   OverflowOut = c(N) XOR c(N-1) (le resultat signe sort de la plage)
--   ZeroOut     = 1 si S = 0
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity addsubN is
    generic ( N : positive := 4 );
    port (
        A           : in  STD_LOGIC_VECTOR(N-1 downto 0);
        B           : in  STD_LOGIC_VECTOR(N-1 downto 0);
        AddSub      : in  STD_LOGIC;
        S           : out STD_LOGIC_VECTOR(N-1 downto 0);
        CarryOut    : out STD_LOGIC;
        OverflowOut : out STD_LOGIC;
        ZeroOut     : out STD_LOGIC
    );
end addsubN;

architecture structurel of addsubN is

    component rcaN
        generic ( N : positive );
        port (
            A, B : in  STD_LOGIC_VECTOR(N-1 downto 0);
            cin  : in  STD_LOGIC;
            S    : out STD_LOGIC_VECTOR(N-1 downto 0);
            cn1  : out STD_LOGIC;
            cout : out STD_LOGIC
        );
    end component;

    signal Bx, Sint : STD_LOGIC_VECTOR(N-1 downto 0);
    signal ou       : STD_LOGIC_VECTOR(N-1 downto 0);  -- OU cumulatif des bits de S
    signal cn1, cn  : STD_LOGIC;

begin

    -- Portes XOR : inversent B quand AddSub = '1'
    INV : for i in 0 to N-1 generate
        Bx(i) <= B(i) xor AddSub;
    end generate;

    -- AddSub sert aussi de retenue entrante (le "+1" du complement a 2)
    RCA : rcaN generic map (N => N)
               port map (A => A, B => Bx, cin => AddSub, S => Sint, cn1 => cn1, cout => cn);

    -- Detection de zero : chaine de portes OU sur les bits de S, puis inversion
    ou(0) <= Sint(0);
    CHAINE_OU : for i in 1 to N-1 generate
        ou(i) <= ou(i-1) or Sint(i);
    end generate;

    S           <= Sint;
    CarryOut    <= cn;
    OverflowOut <= cn xor cn1;
    ZeroOut     <= not ou(N-1);

end structurel;
