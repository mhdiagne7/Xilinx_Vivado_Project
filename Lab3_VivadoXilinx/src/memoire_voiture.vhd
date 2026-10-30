-- Memoire de la voiture en attente sur la rue secondaire (1 bascule).
-- Le bouton capteur (BTNU), une fois anti-rebondi, peut n'etre appuye qu'un
-- instant ; la FSM ne regarde SSCS qu'une fois par seconde. La memoire retient
-- l'appui jusqu'a ce que la rue secondaire passe au vert (la voiture passe).
--   D = (Bouton OU Voiture) ET NON(VertSS)
-- Cadencee a 100 Hz comme l'anti-rebond, pour ne manquer aucun appui.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memoire_voiture is
    port (
        GClock    : in  STD_LOGIC;   -- horloge 100 Hz
        GResetBar : in  STD_LOGIC;   -- reset actif a 0
        Bouton    : in  STD_LOGIC;   -- capteur anti-rebondi
        VertSS    : in  STD_LOGIC;   -- SSTL0 de la FSM : la voiture passe
        Voiture   : out STD_LOGIC    -- SSCS vers la FSM
    );
end memoire_voiture;

architecture structurel of memoire_voiture is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal M, Mb, D : STD_LOGIC;

begin

    D <= (Bouton or M) and (not VertSS);

    FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => D, i_enable => '1',
                             i_clock => GClock, o_q => M, o_qBar => Mb);

    Voiture <= M;

end structurel;
