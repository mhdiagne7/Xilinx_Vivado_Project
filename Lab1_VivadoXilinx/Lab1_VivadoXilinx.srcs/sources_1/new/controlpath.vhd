-- Logique de commande, methode une-bascule-par-etat (one-hot).
--   S0 : initialisation   DISPLAY <- 0, LMASK <- 00000001, RMASK <- 10000000
--   S1 : LEFT et RIGHT    DISPLAY <- LMASK or RMASK, LMASK <<, RMASK >>
--   S2 : LEFT seul        DISPLAY <- LMASK, LMASK <<
--   S3 : RIGHT seul       DISPLAY <- RMASK, RMASK >>
--   S4 : aucun            DISPLAY <- 0 (les masques gardent leur position)
-- Chaque etat retourne a la boite de condition, donc l'etat suivant ne
-- depend que de LEFT/RIGHT. Les bascules n'avancent que sur en = '1'.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controlpath is
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
end controlpath;

architecture structurel of controlpath is

    component bascule_D_AS
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

    component bascule_D_AR
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

    signal S0, S1, S2, S3, S4 : STD_LOGIC;
    signal D_S1, D_S2, D_S3, D_S4 : STD_LOGIC;

begin

    -- Logique de transition d'etat
    D_S1 <= LEFT_sw and RIGHT_sw;
    D_S2 <= LEFT_sw and (not RIGHT_sw);
    D_S3 <= RIGHT_sw and (not LEFT_sw);
    D_S4 <= (not LEFT_sw) and (not RIGHT_sw);

    -- Les 5 bascules (S0 est mise a 1 par le reset, les autres a 0)
    FF_S0 : bascule_D_AS port map (clk => clk, reset => reset, en => en, D => '0',  Q => S0);
    FF_S1 : bascule_D_AR port map (clk => clk, reset => reset, en => en, D => D_S1, Q => S1);
    FF_S2 : bascule_D_AR port map (clk => clk, reset => reset, en => en, D => D_S2, Q => S2);
    FF_S3 : bascule_D_AR port map (clk => clk, reset => reset, en => en, D => D_S3, Q => S3);
    FF_S4 : bascule_D_AR port map (clk => clk, reset => reset, en => en, D => D_S4, Q => S4);

    -- Signaux de commande
    loadDis   <= '1';
    loadL     <= S0 or S1 or S2;
    loadR     <= S0 or S1 or S3;
    selL      <= S1 or S2;          -- 0 : valeur initiale, 1 : masque decale
    selR      <= S1 or S3;
    selDis(0) <= S1 or S2;          -- 00 : 0, 01 : LMASK, 10 : RMASK, 11 : LMASK or RMASK
    selDis(1) <= S1 or S3;

end structurel;
