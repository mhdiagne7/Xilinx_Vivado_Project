-- Synchroniseur a deux bascules pour InfoClavier, structurel.
-- InfoClavier vient du clavier, donc d'un domaine d'horloge different :
-- deux bascules en serie sur l'horloge globale evitent qu'une metastabilite
-- de la premiere bascule atteigne la FSM ou le registre a decalage.
-- Delai : 2 cycles (20 ns), negligeable devant la duree d'un bit (60 a 100 us).
-- Reset : sortie a 1, la valeur de repos de la ligne PS/2.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchroniseur is
    port (
        GClock    : in  STD_LOGIC;   -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;   -- reset global, actif a 0
        Entree    : in  STD_LOGIC;   -- signal asynchrone (InfoClavier)
        Sortie    : out STD_LOGIC    -- signal synchronise
    );
end synchroniseur;

architecture structurel of synchroniseur is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    -- Les bascules memorisent la valeur inversee : apres le reset (Q = 0),
    -- la sortie vaut donc 1, comme une ligne PS/2 au repos.
    signal nEntree, q1, q1b, q2, q2b : STD_LOGIC;

begin

    nEntree <= not Entree;
    FF1 : enARdFF_2 port map (i_resetBar => GResetBar, i_d => nEntree, i_enable => '1',
                              i_clock => GClock, o_q => q1, o_qBar => q1b);
    FF2 : enARdFF_2 port map (i_resetBar => GResetBar, i_d => q1, i_enable => '1',
                              i_clock => GClock, o_q => q2, o_qBar => q2b);

    Sortie <= q2b;

end structurel;
