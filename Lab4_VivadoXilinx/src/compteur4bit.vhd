-- Compteur 4 bits des bits recus, structurel.
--  * RAZ = 1    : le compteur est force a 0 (prioritaire) ;
--  * Decale = 1 : le compteur avance de 1 (un passage dans l'etat C) ;
--  * sinon      : il garde sa valeur.
-- Realisation : 4 bascules enARdFF_2, un incrementeur de 4 demi-additionneurs
-- (C + 1), et pour chaque bit  D = S.RAZ'  avec validation = Decale + RAZ.
-- Fin = 1 quand le compteur vaut 9 (1001) : pendant le 10e passage en C
-- (bit d'arret), le compteur montre encore la valeur d'avant l'increment.
--     Fin = c3.c2'.c1'.c0
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity compteur4bit is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;                     -- reset global, actif a 0
        RAZ       : in  STD_LOGIC;                     -- remise a zero synchrone
        Decale    : in  STD_LOGIC;                     -- comptage
        Fin       : out STD_LOGIC;                     -- compteur = 9
        Valeur    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end compteur4bit;

architecture structurel of compteur4bit is

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
        port (a, b : in STD_LOGIC; s, c : out STD_LOGIC);
    end component;

    signal Cpt, CptB : STD_LOGIC_VECTOR(3 downto 0);   -- valeur et inverse
    signal S         : STD_LOGIC_VECTOR(3 downto 0);   -- Cpt + 1
    signal Ret       : STD_LOGIC_VECTOR(4 downto 0);   -- retenues (Ret(0) = 1)
    signal D         : STD_LOGIC_VECTOR(3 downto 0);
    signal Valide    : STD_LOGIC;

begin

    -- Incrementeur : chaine de demi-additionneurs, retenue d'entree = 1
    Ret(0) <= '1';
    INC : for i in 0 to 3 generate
        HA : demi_additionneur port map (a => Cpt(i), b => Ret(i), s => S(i), c => Ret(i + 1));
    end generate;

    -- RAZ prioritaire : D = S.RAZ', validation = Decale + RAZ
    Valide <= Decale or RAZ;
    REG : for i in 0 to 3 generate
        D(i) <= S(i) and not RAZ;
        FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => D(i), i_enable => Valide,
                                 i_clock => GClock, o_q => Cpt(i), o_qBar => CptB(i));
    end generate;

    -- Comparateur : compteur = 9
    Fin    <= Cpt(3) and CptB(2) and CptB(1) and Cpt(0);
    Valeur <= Cpt;

end structurel;
