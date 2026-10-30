-- Controleur de feux de circulation : entite de niveau superieur (Nexys A7-100T).
-- Ports du tableau 10 de l'enonce.
--   clk_div      : 100 MHz -> 1 Hz (FSM), 100 Hz (anti-rebond), 1 kHz (affichage)
--   systeme_feux : FSM, compteurs, minuterie, anti-rebond, memoire voiture
--   affichage    : compteur en decimal sur deux chiffres (bonus)
-- LED RGB : vrai jaune = rouge + vert allumes ensemble (melange de couleurs,
-- enonce section 4.2.2). Le canal bleu (MSTL(1), SSTL(1)) reste eteint.
--   MSTL(2) -> rouge LD16 = rouge OU jaune
--   MSTL(1) -> bleu  LD16 = 0
--   MSTL(0) -> vert  LD16 = vert OU jaune     (meme chose pour SSTL et LD17)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controleur_feux is
    port (
        CLOCK    : in  STD_LOGIC;                     -- oscillateur 100 MHz (E3)
        RESETBAR : in  STD_LOGIC;                     -- CPU_RESETN, actif a 0
        LOAD_FSM : in  STD_LOGIC;                     -- SW0
        CAPTEUR  : in  STD_LOGIC;                     -- BTNU
        MSC_MAX  : in  STD_LOGIC_VECTOR(3 downto 0);  -- SW4..SW1
        SSC_MAX  : in  STD_LOGIC_VECTOR(3 downto 0);  -- SW8..SW5
        MSTL     : out STD_LOGIC_VECTOR(2 downto 0);  -- LED RGB LD16 (R, B, G)
        SSTL     : out STD_LOGIC_VECTOR(2 downto 0);  -- LED RGB LD17 (R, B, G)
        SEG      : out STD_LOGIC_VECTOR(6 downto 0);  -- cathodes CA..CG
        AN       : out STD_LOGIC_VECTOR(7 downto 0)   -- anodes AN0..AN7
    );
end controleur_feux;

architecture structurel of controleur_feux is

    component clk_div
        port (
            clock_100Mhz : in  STD_LOGIC;
            clock_1MHz, clock_100KHz, clock_10KHz, clock_1KHz : out STD_LOGIC;
            clock_100Hz, clock_10Hz, clock_1Hz                : out STD_LOGIC
        );
    end component;

    component systeme_feux
        port (
            Clk1Hz, Clk100Hz, GResetBar, Load, Capteur : in STD_LOGIC;
            MSC, SSC   : in  STD_LOGIC_VECTOR(3 downto 0);
            MSTL, SSTL : out STD_LOGIC_VECTOR(2 downto 0);
            Compteur   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component affichage
        port (
            Clk1kHz, GResetBar : in  STD_LOGIC;
            Valeur : in  STD_LOGIC_VECTOR(3 downto 0);
            SEG    : out STD_LOGIC_VECTOR(6 downto 0);
            AN     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal clk1Hz, clk100Hz, clk1kHz : STD_LOGIC;
    signal ms, ss                    : STD_LOGIC_VECTOR(2 downto 0);   -- feux one-hot
    signal valeur                    : STD_LOGIC_VECTOR(3 downto 0);

begin

    DIV : clk_div port map (clock_100Mhz => CLOCK, clock_1MHz => open, clock_100KHz => open,
                            clock_10KHz => open, clock_1KHz => clk1kHz, clock_100Hz => clk100Hz,
                            clock_10Hz => open, clock_1Hz => clk1Hz);

    SYS : systeme_feux port map (Clk1Hz => clk1Hz, Clk100Hz => clk100Hz, GResetBar => RESETBAR,
                                 Load => LOAD_FSM, Capteur => CAPTEUR, MSC => MSC_MAX, SSC => SSC_MAX,
                                 MSTL => ms, SSTL => ss, Compteur => valeur);

    AFF : affichage port map (Clk1kHz => clk1kHz, GResetBar => RESETBAR, Valeur => valeur,
                              SEG => SEG, AN => AN);

    -- Melange de couleurs : jaune = rouge + vert
    MSTL(2) <= ms(2) or ms(1);
    MSTL(1) <= '0';
    MSTL(0) <= ms(0) or ms(1);
    SSTL(2) <= ss(2) or ss(1);
    SSTL(1) <= '0';
    SSTL(0) <= ss(0) or ss(1);

end structurel;
