-- Filtre numerique de l'horloge du clavier (figure 13 de l'enonce), structurel.
-- 1) Registre a decalage de 8 bascules cadence a 100 MHz : HC(0) recoit
--    HorlogeClavier, HC(i) recoit HC(i-1). Il echantillonne l'horloge du
--    clavier et sert aussi de synchroniseur (entree asynchrone).
-- 2) Circuit combinatoire : Set   = HC(7).HC(6)...HC(0)    (8 echantillons a 1)
--                           Reset = HC(7)'.HC(6)'...HC(0)' (8 echantillons a 0)
-- 3) Bascule SR realisee avec une bascule D synchrone :
--        D = Set + Q.Reset'
--    La sortie ne change que si l'horloge du clavier est restee au meme
--    niveau pendant 8 periodes de 100 MHz (80 ns) : les parasites et les
--    reflexions plus courts sont ignores. Contrairement au verrou SR de la
--    figure 13, cette bascule est synchrone : pas de boucle combinatoire,
--    donc pas besoin de la derogation ALLOW_COMBINATORIAL_LOOPS (section 8.3).
-- Reset global (actif a 0) : registre et sortie a 0.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity filtre_digitale is
    port (
        GClock         : in  STD_LOGIC;   -- horloge globale 100 MHz
        GResetBar      : in  STD_LOGIC;   -- reset global, actif a 0
        HorlogeClavier : in  STD_LOGIC;   -- horloge brute du clavier (PS2_CLK)
        HorlogeFiltree : out STD_LOGIC    -- horloge filtree (clk_filtree)
    );
end filtre_digitale;

architecture structurel of filtre_digitale is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal HC, HCb   : STD_LOGIC_VECTOR(7 downto 0);   -- echantillons et leurs inverses
    signal Entrees   : STD_LOGIC_VECTOR(7 downto 0);   -- entrees D du registre
    signal SetF      : STD_LOGIC;                      -- 8 echantillons a 1
    signal ResetF    : STD_LOGIC;                      -- 8 echantillons a 0
    signal Q, Qb, Dsr : STD_LOGIC;                     -- bascule SR synchrone

begin

    -- Registre a decalage de 8 bits
    Entrees <= HC(6 downto 0) & HorlogeClavier;
    REG : for i in 0 to 7 generate
        FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Entrees(i), i_enable => '1',
                                 i_clock => GClock, o_q => HC(i), o_qBar => HCb(i));
    end generate;

    -- Circuit combinatoire : deux portes ET a 8 entrees
    SetF   <= HC(7) and HC(6) and HC(5) and HC(4) and HC(3) and HC(2) and HC(1) and HC(0);
    ResetF <= HCb(7) and HCb(6) and HCb(5) and HCb(4) and HCb(3) and HCb(2) and HCb(1) and HCb(0);

    -- Bascule SR synchrone : D = Set + Q.Reset'
    Dsr <= SetF or (Q and not ResetF);
    FF_SR : enARdFF_2 port map (i_resetBar => GResetBar, i_d => Dsr, i_enable => '1',
                                i_clock => GClock, o_q => Q, o_qBar => Qb);

    HorlogeFiltree <= Q;

end structurel;
