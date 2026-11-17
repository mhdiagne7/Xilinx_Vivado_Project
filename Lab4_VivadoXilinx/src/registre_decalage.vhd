-- Registre a decalage de 10 bits pour la trame PS/2, structurel.
-- Quand Decale = 1, le bit Info entre a gauche (position 9) et les autres se
-- decalent vers la droite. Le bit de depart n'est pas decale (la FSM ne
-- passe en C qu'a partir du premier bit de donnees). Apres les 10 decalages
-- d'une trame (d0..d7, parite, arret, LSB en premier) :
--     position : 9     8   7  6  5  4  3  2  1  0
--     contenu  : arret P   d7 d6 d5 d4 d3 d2 d1 d0
-- L'octet recu se trouve donc dans les positions 7 a 0, dans le bon ordre.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registre_decalage is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;                     -- reset global, actif a 0
        Decale    : in  STD_LOGIC;                     -- validation du decalage
        Info      : in  STD_LOGIC;                     -- bit entrant (InfoClavier synchronise)
        Trame     : out STD_LOGIC_VECTOR(9 downto 0);  -- contenu complet
        Octet     : out STD_LOGIC_VECTOR(7 downto 0)   -- code de balayage recu
    );
end registre_decalage;

architecture structurel of registre_decalage is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal Q, Qb, D : STD_LOGIC_VECTOR(9 downto 0);

begin

    D <= Info & Q(9 downto 1);
    REG : for i in 0 to 9 generate
        FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => D(i), i_enable => Decale,
                                 i_clock => GClock, o_q => Q(i), o_qBar => Qb(i));
    end generate;

    Trame <= Q;
    Octet <= Q(7 downto 0);

end structurel;
