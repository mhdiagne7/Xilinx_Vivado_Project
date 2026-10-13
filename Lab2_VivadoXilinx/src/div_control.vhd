-- Logique de commande du diviseur, methode une-bascule-par-etat (one-hot).
-- Memes etats et memes transitions que le multiplicateur :
--   S0 : chargement   loadR, loadD, loadQ, loadC, loadS (toutes les selections a 0)
--   S1 : essai        si Z0 = 0 : loadQ, selQ (+ loadR, selR si Acc = 1)
--   S2 : decalage     loadD, loadC (selD = 1, selC = 1)
--   S3 : fini         Done
--   S1+ = S0 + S2      S2+ = S1.Z0'      S3+ = S1.Z0 + S3
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_control is
    port (
        GClock, GReset : in  STD_LOGIC;
        -- signaux d'etat du chemin de donnees
        Acc, Z0        : in  STD_LOGIC;
        -- signaux de commande
        loadR, selR, loadD, selD, loadQ, selQ, loadC, selC, loadS : out STD_LOGIC;
        Done           : out STD_LOGIC
    );
end div_control;

architecture structurel of div_control is

    component bascule_D_AS
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

    component bascule_D_AR
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

    signal S0, S1, S2, S3   : STD_LOGIC;
    signal D_S1, D_S2, D_S3 : STD_LOGIC;

begin

    -- Logique d'etat suivant
    D_S1 <= S0 or S2;
    D_S2 <= S1 and (not Z0);
    D_S3 <= (S1 and Z0) or S3;

    -- Les 4 bascules (S0 mise a 1 par GReset, les autres a 0)
    FF_S0 : bascule_D_AS port map (clk => GClock, reset => GReset, en => '1', D => '0',  Q => S0);
    FF_S1 : bascule_D_AR port map (clk => GClock, reset => GReset, en => '1', D => D_S1, Q => S1);
    FF_S2 : bascule_D_AR port map (clk => GClock, reset => GReset, en => '1', D => D_S2, Q => S2);
    FF_S3 : bascule_D_AR port map (clk => GClock, reset => GReset, en => '1', D => D_S3, Q => S3);

    -- Logique de sortie (lue dans l'ASM detaille)
    loadS <= S0;
    loadR <= S0 or (S1 and (not Z0) and Acc);
    selR  <= S1;
    loadD <= S0 or S2;
    selD  <= S2;
    loadQ <= S0 or (S1 and (not Z0));
    selQ  <= S1;
    loadC <= S0 or S2;
    selC  <= S2;
    Done  <= S3;

end structurel;
