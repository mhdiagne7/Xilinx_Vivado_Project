-- Unite d'addition/soustraction 4 bits en complement a 2 (figure 6).
--   AddSub = '0' : S = A + B         (B passe tel quel, c0 = 0)
--   AddSub = '1' : S = A + not B + 1 = A - B
-- Signaux d'etat :
--   CarryOut    = c4, retenue sortant du dernier additionneur complet.
--                 En soustraction (A + not B + 1), c4 = 1 veut dire
--                 "pas d'emprunt" (A >= B en non signe).
--   OverflowOut = c4 XOR c3 (le resultat signe sort de -8..+7)
--   ZeroOut     = 1 si S = 0000
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity addsub4 is
    port (
        A           : in  STD_LOGIC_VECTOR(3 downto 0);
        B           : in  STD_LOGIC_VECTOR(3 downto 0);
        AddSub      : in  STD_LOGIC;
        S           : out STD_LOGIC_VECTOR(3 downto 0);
        CarryOut    : out STD_LOGIC;
        OverflowOut : out STD_LOGIC;
        ZeroOut     : out STD_LOGIC
    );
end addsub4;

architecture structurel of addsub4 is

    component rca4
        port (
            A, B : in  STD_LOGIC_VECTOR(3 downto 0);
            cin  : in  STD_LOGIC;
            S    : out STD_LOGIC_VECTOR(3 downto 0);
            c3   : out STD_LOGIC;
            cout : out STD_LOGIC
        );
    end component;

    signal Bx   : STD_LOGIC_VECTOR(3 downto 0);
    signal Sint : STD_LOGIC_VECTOR(3 downto 0);
    signal c3, c4 : STD_LOGIC;

begin

    -- Portes XOR : inversent B quand AddSub = '1'
    Bx(0) <= B(0) xor AddSub;
    Bx(1) <= B(1) xor AddSub;
    Bx(2) <= B(2) xor AddSub;
    Bx(3) <= B(3) xor AddSub;

    -- AddSub sert aussi de retenue entrante (le "+1" du complement a 2)
    RCA : rca4 port map (A => A, B => Bx, cin => AddSub, S => Sint, c3 => c3, cout => c4);

    S           <= Sint;
    CarryOut    <= c4;
    OverflowOut <= c4 xor c3;
    ZeroOut     <= not (Sint(3) or Sint(2) or Sint(1) or Sint(0));

end structurel;
