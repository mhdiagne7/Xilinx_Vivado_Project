-- Minuterie des feux jaunes (2 bits), commune aux deux rues : les deux jaunes
-- ne sont jamais allumes en meme temps.
-- A chaque front de l'horloge 1 Hz (si Load = 1) :
--   un jaune est allume (JauneMS ou JauneSS) : T <- T + 1
--   aucun jaune                              : T <- 00
-- Durees fixes (non programmables, enonce section 4.2.2) :
--   MTE = 1 quand T = 2 pendant le jaune MS -> jaune MS de 3 s
--   STE = 1 quand T = 1 pendant le jaune SS -> jaune SS de 2 s
-- (la FSM change d'etat au front suivant, d'ou la seconde de plus)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity minuterie_jaunes is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge 1 Hz
        GResetBar : in  STD_LOGIC;                     -- reset actif a 0
        Load      : in  STD_LOGIC;                     -- 1 = la minuterie avance
        JauneMS   : in  STD_LOGIC;                     -- MSTL1 de la FSM
        JauneSS   : in  STD_LOGIC;                     -- SSTL1 de la FSM
        MTE       : out STD_LOGIC;                     -- jaune MS termine
        STE       : out STD_LOGIC;                     -- jaune SS termine
        Valeur    : out STD_LOGIC_VECTOR(1 downto 0)   -- valeur de la minuterie
    );
end minuterie_jaunes;

architecture structurel of minuterie_jaunes is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    component demi_additionneur
        port ( a, b : in STD_LOGIC; s, c : out STD_LOGIC );
    end component;

    signal T, Tb  : STD_LOGIC_VECTOR(1 downto 0);   -- valeur actuelle et inverse
    signal Inc    : STD_LOGIC_VECTOR(1 downto 0);   -- T + 1
    signal ret    : STD_LOGIC_VECTOR(1 downto 0);   -- retenues
    signal Jaune  : STD_LOGIC;                      -- un des deux jaunes est allume
    signal D      : STD_LOGIC_VECTOR(1 downto 0);   -- entrees des bascules

begin

    Jaune <= JauneMS or JauneSS;

    -- Incrementeur : T + 1 avec 2 demi-additionneurs
    HA0 : demi_additionneur port map (a => T(0), b => '1',    s => Inc(0), c => ret(0));
    HA1 : demi_additionneur port map (a => T(1), b => ret(0), s => Inc(1), c => ret(1));

    -- Compte pendant un jaune, remise a 0 sinon
    BITS : for i in 0 to 1 generate
        D(i) <= Inc(i) and Jaune;
        FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => D(i), i_enable => Load,
                                 i_clock => GClock, o_q => T(i), o_qBar => Tb(i));
    end generate;

    -- Comparateurs avec les durees fixes, valides seulement pendant le bon jaune
    MTE <= T(1) and Tb(0) and JauneMS;   -- T = 2 (10)
    STE <= Tb(1) and T(0) and JauneSS;   -- T = 1 (01)

    Valeur <= T;

end structurel;
