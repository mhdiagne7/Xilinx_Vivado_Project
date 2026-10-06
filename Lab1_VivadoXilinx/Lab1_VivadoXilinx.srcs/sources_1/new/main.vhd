-- Entite de niveau superieur : controleur d'affichage (displayController).
-- Noms de ports selon le tableau 2 de l'enonce (Nexys A7-100T).
--   CLK100MHZ = GClock, SW_RESET = GReset, SW_LEFT = Left, SW_RIGHT = Right,
--   LED_OUT   = DisplayOut[7..0]
-- Tous les registres tournent sur l'horloge 100 MHz et n'avancent que sur
-- l'impulsion "tick" du diviseur (~1 Hz). N est un generic pour la simulation.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    generic (
        N_DIV : positive := 100_000_000
    );
    port (
        CLK100MHZ : in  STD_LOGIC;
        SW_RESET  : in  STD_LOGIC;
        SW_LEFT   : in  STD_LOGIC;
        SW_RIGHT  : in  STD_LOGIC;
        LED_OUT   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end main;

architecture structurel of main is

    component diviseur_horloge
        generic ( N : positive );
        port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            tick  : out STD_LOGIC
        );
    end component;

    component datapath
        port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            en         : in  STD_LOGIC;
            loadDis    : in  STD_LOGIC;
            selDis     : in  STD_LOGIC_VECTOR(1 downto 0);
            loadL      : in  STD_LOGIC;
            selL       : in  STD_LOGIC;
            loadR      : in  STD_LOGIC;
            selR       : in  STD_LOGIC;
            DISPLAY_out: out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component controlpath
        port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            en      : in  STD_LOGIC;
            LEFT_sw : in  STD_LOGIC;
            RIGHT_sw: in  STD_LOGIC;
            loadDis : out STD_LOGIC;
            selDis  : out STD_LOGIC_VECTOR(1 downto 0);
            loadL   : out STD_LOGIC;
            selL    : out STD_LOGIC;
            loadR   : out STD_LOGIC;
            selR    : out STD_LOGIC
        );
    end component;

    signal sig_en      : STD_LOGIC;
    signal sig_loadDis : STD_LOGIC;
    signal sig_selDis  : STD_LOGIC_VECTOR(1 downto 0);
    signal sig_loadL   : STD_LOGIC;
    signal sig_selL    : STD_LOGIC;
    signal sig_loadR   : STD_LOGIC;
    signal sig_selR    : STD_LOGIC;

begin

    U_DIV : diviseur_horloge
        generic map ( N => N_DIV )
        port map (
            clk   => CLK100MHZ,
            reset => SW_RESET,
            tick  => sig_en
        );

    U_CTRL : controlpath port map (
        clk      => CLK100MHZ,
        reset    => SW_RESET,
        en       => sig_en,
        LEFT_sw  => SW_LEFT,
        RIGHT_sw => SW_RIGHT,
        loadDis  => sig_loadDis,
        selDis   => sig_selDis,
        loadL    => sig_loadL,
        selL     => sig_selL,
        loadR    => sig_loadR,
        selR     => sig_selR
    );

    U_DP : datapath port map (
        clk         => CLK100MHZ,
        reset       => SW_RESET,
        en          => sig_en,
        loadDis     => sig_loadDis,
        selDis      => sig_selDis,
        loadL       => sig_loadL,
        selL        => sig_selL,
        loadR       => sig_loadR,
        selR        => sig_selR,
        DISPLAY_out => LED_OUT
    );

end structurel;
