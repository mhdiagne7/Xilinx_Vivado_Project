-- Compteur du feu vert d'une rue (4 bits) avec comparateur d'egalite.
-- Utilise deux fois : rue principale (Vert = MSTL0, Max = MSC) -> Fini = MSCE
--                     rue secondaire (Vert = SSTL0, Max = SSC) -> Fini = SSCE
-- A chaque front de l'horloge 1 Hz (si Load = 1) :
--   Vert = 0              : Valeur <- 0000 (pret pour le prochain vert)
--   Vert = 1, Valeur < Max : Valeur <- Valeur + 1
--   Vert = 1, Valeur = Max : Valeur ne bouge plus (bloque a Max)
-- Fini = 1 quand Valeur = Max (4 portes XNOR + 1 porte ET).
-- Le vert dure donc Max + 1 secondes (une seconde pour que la FSM reagisse).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity compteur_vert is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge 1 Hz
        GResetBar : in  STD_LOGIC;                     -- reset actif a 0
        Load      : in  STD_LOGIC;                     -- 1 = le compteur avance
        Vert      : in  STD_LOGIC;                     -- feu vert de cette rue
        Max       : in  STD_LOGIC_VECTOR(3 downto 0);  -- MSC ou SSC
        Fini      : out STD_LOGIC;                     -- Valeur = Max
        Valeur    : out STD_LOGIC_VECTOR(3 downto 0)   -- valeur du compteur
    );
end compteur_vert;

architecture structurel of compteur_vert is

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

    signal C     : STD_LOGIC_VECTOR(3 downto 0);   -- valeur actuelle
    signal Cb    : STD_LOGIC_VECTOR(3 downto 0);   -- sorties Q' (non utilisees)
    signal Inc   : STD_LOGIC_VECTOR(3 downto 0);   -- C + 1
    signal ret   : STD_LOGIC_VECTOR(3 downto 0);   -- retenues de l'incrementeur
    signal egal  : STD_LOGIC_VECTOR(3 downto 0);   -- egalite bit a bit
    signal estFini : STD_LOGIC;
    signal Suiv  : STD_LOGIC_VECTOR(3 downto 0);   -- C + 1 ou C (multiplexeur)
    signal D     : STD_LOGIC_VECTOR(3 downto 0);   -- entrees des bascules

begin

    -- Incrementeur : C + 1 avec 4 demi-additionneurs en chaine
    HA0 : demi_additionneur port map (a => C(0), b => '1',    s => Inc(0), c => ret(0));
    HA1 : demi_additionneur port map (a => C(1), b => ret(0), s => Inc(1), c => ret(1));
    HA2 : demi_additionneur port map (a => C(2), b => ret(1), s => Inc(2), c => ret(2));
    HA3 : demi_additionneur port map (a => C(3), b => ret(2), s => Inc(3), c => ret(3));

    -- Comparateur d'egalite : chaque bit de C egal au bit de Max
    egal    <= not (C xor Max);
    estFini <= egal(3) and egal(2) and egal(1) and egal(0);

    -- Multiplexeur : C + 1 tant que Max n'est pas atteint, sinon C (bloque)
    BITS : for i in 0 to 3 generate
        Suiv(i) <= (Inc(i) and not estFini) or (C(i) and estFini);
        D(i)    <= Suiv(i) and Vert;   -- feu pas vert : remise a 0
        FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => D(i), i_enable => Load,
                                 i_clock => GClock, o_q => C(i), o_qBar => Cb(i));
    end generate;

    Fini   <= estFini;
    Valeur <= C;

end structurel;
