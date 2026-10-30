-- Systeme de feux de circulation, sans le diviseur d'horloge ni l'affichage
-- (schema bloc du rapport). Recoit directement les horloges lentes, ce qui
-- permet de le simuler en secondes reelles.
--   CAPTEUR -> debouncer_2 -> memoire_voiture -> SSCS
--   compteur_vert (MS) -> MSCE    compteur_vert (SS) -> SSCE
--   minuterie_jaunes   -> MTE, STE
--   fsm_controleur     -> MSTL, SSTL (et commande les compteurs en retour)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity systeme_feux is
    port (
        Clk1Hz    : in  STD_LOGIC;                     -- FSM, compteurs, minuterie
        Clk100Hz  : in  STD_LOGIC;                     -- anti-rebond et memoire
        GResetBar : in  STD_LOGIC;                     -- reset actif a 0
        Load      : in  STD_LOGIC;                     -- LOAD_FSM : 0 = fige
        Capteur   : in  STD_LOGIC;                     -- bouton brut (BTNU)
        MSC       : in  STD_LOGIC_VECTOR(3 downto 0);  -- duree du vert MS
        SSC       : in  STD_LOGIC_VECTOR(3 downto 0);  -- duree du vert SS
        MSTL      : out STD_LOGIC_VECTOR(2 downto 0);  -- feu MS (rouge, jaune, vert)
        SSTL      : out STD_LOGIC_VECTOR(2 downto 0);  -- feu SS (rouge, jaune, vert)
        Compteur  : out STD_LOGIC_VECTOR(3 downto 0)   -- compteur du vert en cours
    );
end systeme_feux;

architecture structurel of systeme_feux is

    component debouncer_2
        port ( i_resetBar, i_clock, i_raw : in STD_LOGIC; o_clean : out STD_LOGIC );
    end component;

    component memoire_voiture
        port ( GClock, GResetBar, Bouton, VertSS : in STD_LOGIC; Voiture : out STD_LOGIC );
    end component;

    component compteur_vert
        port (
            GClock, GResetBar, Load, Vert : in  STD_LOGIC;
            Max    : in  STD_LOGIC_VECTOR(3 downto 0);
            Fini   : out STD_LOGIC;
            Valeur : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component minuterie_jaunes
        port (
            GClock, GResetBar, Load, JauneMS, JauneSS : in STD_LOGIC;
            MTE, STE : out STD_LOGIC;
            Valeur   : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component fsm_controleur
        port (
            GClock, GResetBar, Load    : in  STD_LOGIC;
            SSCS, MSCE, MTE, SSCE, STE : in  STD_LOGIC;
            MSTL, SSTL                 : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    signal Propre, SSCS            : STD_LOGIC;
    signal MSCE, SSCE, MTE, STE    : STD_LOGIC;
    signal ms, ss                  : STD_LOGIC_VECTOR(2 downto 0);
    signal ValMS, ValSS            : STD_LOGIC_VECTOR(3 downto 0);
    signal ValT                    : STD_LOGIC_VECTOR(1 downto 0);

begin

    DEB : debouncer_2 port map (i_resetBar => GResetBar, i_clock => Clk100Hz,
                                i_raw => Capteur, o_clean => Propre);

    MEM : memoire_voiture port map (GClock => Clk100Hz, GResetBar => GResetBar,
                                    Bouton => Propre, VertSS => ss(0), Voiture => SSCS);

    CPT_MS : compteur_vert port map (GClock => Clk1Hz, GResetBar => GResetBar, Load => Load,
                                     Vert => ms(0), Max => MSC, Fini => MSCE, Valeur => ValMS);

    CPT_SS : compteur_vert port map (GClock => Clk1Hz, GResetBar => GResetBar, Load => Load,
                                     Vert => ss(0), Max => SSC, Fini => SSCE, Valeur => ValSS);

    MIN : minuterie_jaunes port map (GClock => Clk1Hz, GResetBar => GResetBar, Load => Load,
                                     JauneMS => ms(1), JauneSS => ss(1),
                                     MTE => MTE, STE => STE, Valeur => ValT);

    FSM : fsm_controleur port map (GClock => Clk1Hz, GResetBar => GResetBar, Load => Load,
                                   SSCS => SSCS, MSCE => MSCE, MTE => MTE, SSCE => SSCE, STE => STE,
                                   MSTL => ms, SSTL => ss);

    MSTL <= ms;
    SSTL <= ss;

    -- Un seul compteur de vert est actif a la fois (l'autre est a 0) :
    -- un OU bit a bit donne la valeur du compteur en cours.
    Compteur <= ValMS or ValSS;

end structurel;
