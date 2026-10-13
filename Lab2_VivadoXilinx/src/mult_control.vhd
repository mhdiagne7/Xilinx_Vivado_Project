-- Logique de commande du multiplicateur, methode une-bascule-par-etat (one-hot).
--   S0 : chargement   loadM, loadA, loadQ, loadC (selA = 00, selQ = 0, selC = 0)
--   S1 : test         si Z0 = 0 et Q(0) = 1 : loadA, selA = 01 (+ AddSub si Z1 = 1)
--   S2 : decalage     loadA, loadQ, loadC (selA = 10, selQ = 1, selC = 1)
--   S3 : fini         Done
-- Equations d'etat suivant (lues sur les fleches de l'ASM) :
--   S1+ = S0 + S2      S2+ = S1.Z0'      S3+ = S1.Z0 + S3
-- S0 n'est atteint que par GReset (bascule a mise a 1, D = 0).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mult_control is
    port (
        GClock, GReset : in  STD_LOGIC;
        -- signaux d'etat du chemin de donnees
        Q0, Z0, Z1     : in  STD_LOGIC;
        -- signaux de commande
        loadM, loadA, loadQ, loadC : out STD_LOGIC;
        selA           : out STD_LOGIC_VECTOR(1 downto 0);
        selQ, selC     : out STD_LOGIC;
        AddSub         : out STD_LOGIC;
        Done           : out STD_LOGIC
    );
end mult_control;

architecture structurel of mult_control is

    component bascule_D_AS
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

    component bascule_D_AR
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

    signal S0, S1, S2, S3         : STD_LOGIC;
    signal D_S1, D_S2, D_S3       : STD_LOGIC;

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

    -- Logique de sortie (lue dans les boites et les ovales de l'ASM detaille)
    loadM   <= S0;
    loadQ   <= S0 or S2;
    loadC   <= S0 or S2;
    loadA   <= S0 or S2 or (S1 and (not Z0) and Q0);
    selA(1) <= S2;
    selA(0) <= S1;
    selQ    <= S2;
    selC    <= S2;
    AddSub  <= S1 and Z1;
    Done    <= S3;

end structurel;
