-- Detecteur de front descendant, structurel.
-- Une bascule garde la valeur de l'entree au cycle precedent (Prec).
--     FD = Prec . Entree'
-- FD vaut 1 pendant un seul cycle de 100 MHz, au cycle ou l'horloge filtree
-- passe de 1 a 0 : c'est l'entree FD de la FSM (« un bit vient d'arriver »).
-- FD sert de validation d'horloge (clock enable) : tout le systeme reste sur
-- l'horloge globale, comme le demandent les sections 8.2 et 9 de l'enonce.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detecteur_front is
    port (
        GClock    : in  STD_LOGIC;   -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;   -- reset global, actif a 0
        Entree    : in  STD_LOGIC;   -- horloge filtree du clavier
        FD        : out STD_LOGIC    -- impulsion d'un cycle sur front descendant
    );
end detecteur_front;

architecture structurel of detecteur_front is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal Prec, PrecB : STD_LOGIC;

begin

    FF_PREC : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Entree, i_enable => '1',
                                  i_clock => GClock, o_q => Prec, o_qBar => PrecB);

    FD <= Prec and not Entree;

end structurel;
