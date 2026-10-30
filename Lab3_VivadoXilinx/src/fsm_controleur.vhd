-- Controleur FSM des feux de circulation (machine de Moore, 4 etats).
-- Codage de Gray (y1 y0) : A = 00 MS vert / SS rouge
--                          B = 01 MS jaune / SS rouge
--                          C = 11 MS rouge / SS vert
--                          D = 10 MS rouge / SS jaune
-- Equations d'etat suivant (tables de Karnaugh, etape 7) :
--   Y1 = y1'.y0.MTE + y1.y0 + y1.y0'.STE'
--   Y0 = y1'.y0 + y1'.MSCE.SSCS + y0.SSCE'
-- Equations de sortie (one-hot [2..0] = rouge, jaune, vert) :
--   MSTL0 = y1'.y0'   MSTL1 = y1'.y0   MSTL2 = y1
--   SSTL0 = y1.y0     SSTL1 = y1.y0'   SSTL2 = y1'
-- Bascules enARdFF_2 (fournies par le cours) : reset actif a 0 -> etat A,
-- validation = Load (SW0) : Load = 0 fige la machine.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm_controleur is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge 1 Hz
        GResetBar : in  STD_LOGIC;                     -- reset actif a 0
        Load      : in  STD_LOGIC;                     -- 1 = la machine avance
        SSCS      : in  STD_LOGIC;                     -- voiture sur la rue secondaire
        MSCE      : in  STD_LOGIC;                     -- compteur MS = MSC
        MTE       : in  STD_LOGIC;                     -- jaune MS termine
        SSCE      : in  STD_LOGIC;                     -- compteur SS = SSC
        STE       : in  STD_LOGIC;                     -- jaune SS termine
        MSTL      : out STD_LOGIC_VECTOR(2 downto 0);  -- feu MS (rouge, jaune, vert)
        SSTL      : out STD_LOGIC_VECTOR(2 downto 0)   -- feu SS (rouge, jaune, vert)
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
    signal nSTE, nSSCE      : STD_LOGIC;   -- entrees inversees

begin

    -- Inverseurs des entrees
    nSTE  <= not STE;
    nSSCE <= not SSCE;

    -- Logique d'etat suivant
    Y1n <= (y1b and y0 and MTE) or (y1 and y0) or (y1 and y0b and nSTE);
    Y0n <= (y1b and y0) or (y1b and MSCE and SSCS) or (y0 and nSSCE);

    -- Les 2 bascules d'etat
    FF_Y1 : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Y1n, i_enable => Load,
                                i_clock => GClock, o_q => y1, o_qBar => y1b);
    FF_Y0 : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Y0n, i_enable => Load,
                                i_clock => GClock, o_q => y0, o_qBar => y0b);

    -- Logique de sortie (Moore : ne depend que de l'etat)
    MSTL(0) <= y1b and y0b;   -- MS vert  (A)
    MSTL(1) <= y1b and y0;    -- MS jaune (B)
    MSTL(2) <= y1;            -- MS rouge (C, D)
    SSTL(0) <= y1 and y0;     -- SS vert  (C)
    SSTL(1) <= y1 and y0b;    -- SS jaune (D)
    SSTL(2) <= y1b;           -- SS rouge (A, B)

end structurel;
