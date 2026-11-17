-- Registre d'affichage de 8 bits avec chargement, structurel.
-- Quand Charge = 1, il copie l'octet du registre a decalage ; sinon il garde
-- sa valeur. Il contient donc toujours le dernier octet recu (00 apres le
-- reset), meme pendant qu'une nouvelle trame entre dans le registre a decalage.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registre8 is
    port (
        GClock    : in  STD_LOGIC;                     -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;                     -- reset global, actif a 0
        Charge    : in  STD_LOGIC;                     -- validation du chargement
        D         : in  STD_LOGIC_VECTOR(7 downto 0);
        Q         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end registre8;

architecture structurel of registre8 is

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal Qb : STD_LOGIC_VECTOR(7 downto 0);

begin

    REG : for i in 0 to 7 generate
        FF : enARdFF_2 port map (i_resetBar => GResetBar, i_d => D(i), i_enable => Charge,
                                 i_clock => GClock, o_q => Q(i), o_qBar => Qb(i));
    end generate;

end structurel;
