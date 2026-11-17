-- Controleur FSM du clavier PS/2 (machine de Moore, 3 etats), structurel.
-- Etats (y1 y0) : A = 00 Attente      : RAZ = 1, Charge = 1
--                 B = 01 Attendre bit : aucune sortie
--                 C = 11 Decaler      : Decale = 1 (un seul cycle)
--                 10 = code inutilise (don't care)
-- Transitions : A -> B si FD.Info' (bit de depart), sinon A
--               B -> C si FD (un bit est arrive), sinon B
--               C -> A si Fin (bit d'arret recu), sinon B
-- Equations (tables de Karnaugh du pre-lab, X en 10) :
--   Y1 = y1'.y0.FD
--   Y0 = y1'.y0 + y0.Fin' + y1'.FD.Info'
--   RAZ = Charge = y0'      Decale = y1
-- Si la machine se trouvait par erreur en 10, Y1 = Y0 = 0 : retour en A.
-- Bascules enARdFF_2 du cours : horloge globale 100 MHz, reset global actif
-- a 0 -> etat A.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm_controleur is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;                     -- reset global, actif a 0
        FD        : in  STD_LOGIC;                     -- front descendant de l'horloge filtree
        Info      : in  STD_LOGIC;                     -- InfoClavier (synchronise)
        Fin       : in  STD_LOGIC;                     -- bit d'arret recu (compteur = 9)
        RAZ       : out STD_LOGIC;                     -- remise a zero du compteur
        Charge    : out STD_LOGIC;                     -- copie de l'octet vers l'afficheur
        Decale    : out STD_LOGIC;                     -- decalage + comptage
        Etat      : out STD_LOGIC_VECTOR(1 downto 0)   -- y1 y0 (pour la simulation)
    );
end fsm_controleur;

architecture structurel of fsm_controleur is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal y1, y1b, y0, y0b : STD_LOGIC;   -- etat present (y1b = y1', y0b = y0')
    signal Y1n, Y0n         : STD_LOGIC;   -- etat suivant (entrees D)
    signal nInfo, nFin      : STD_LOGIC;   -- entrees inversees

begin

    -- Inverseurs des entrees
    nInfo <= not Info;
    nFin  <= not Fin;

    -- Logique d'etat suivant
    Y1n <= y1b and y0 and FD;
    Y0n <= (y1b and y0) or (y0 and nFin) or (y1b and FD and nInfo);

    -- Les 2 bascules d'etat
    FF_Y1 : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Y1n, i_enable => '1',
                                i_clock => GClock, o_q => y1, o_qBar => y1b);
    FF_Y0 : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Y0n, i_enable => '1',
                                i_clock => GClock, o_q => y0, o_qBar => y0b);

    -- Logique de sortie (Moore : ne depend que de l'etat)
    RAZ    <= y0b;
    Charge <= y0b;
    Decale <= y1;
    Etat   <= y1 & y0;

end structurel;
