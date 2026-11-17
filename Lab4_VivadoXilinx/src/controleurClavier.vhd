-- Controleur de clavier PS/2 : entite de niveau superieur, structurelle.
-- Lit les trames du clavier (HorlogeClavier, InfoClavier) et affiche le
-- dernier octet recu en hexadecimal sur deux afficheurs 7 segments
-- (AN1 = BCD1, AN0 = BCD2) ; BCD1 et BCD2 sortent aussi sur les LED
-- (tableau 4 : LD15..LD12 et LD7..LD4).
-- Chemin des signaux :
--   HorlogeClavier -> filtre_digitale -> detecteur_front -> FD
--   InfoClavier    -> synchroniseur   -> Info
--   FSM (FD, Info, Fin) -> RAZ, Charge, Decale
--   compteur4bit (RAZ, Decale) -> Fin
--   registre_decalage (Decale, Info) -> Octet -> registre8 (Charge) -> afficheur7seg
-- Tous les blocs utilisent l'horloge globale de 100 MHz et le reset global
-- (CPU_RESETN, actif a 0).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controleurClavier is
    generic (DIV_MAX : natural := 49999);              -- rafraichissement de l'afficheur
    port (
        HorlogeG       : in  STD_LOGIC;                     -- horloge globale 100 MHz
        ResetG         : in  STD_LOGIC;                     -- reset global (CPU_RESETN), actif a 0
        HorlogeClavier : in  STD_LOGIC;                     -- PS2_CLK
        InfoClavier    : in  STD_LOGIC;                     -- PS2_DATA
        BCD1           : out STD_LOGIC_VECTOR(3 downto 0);  -- chiffre de gauche
        BCD2           : out STD_LOGIC_VECTOR(3 downto 0);  -- chiffre de droite
        SEG            : out STD_LOGIC_VECTOR(6 downto 0);  -- cathodes CA..CG
        DP             : out STD_LOGIC;
        AN             : out STD_LOGIC_VECTOR(7 downto 0)   -- anodes
    );
end controleurClavier;

architecture structurel of controleurClavier is

    component filtre_digitale
        port (GClock, GResetBar, HorlogeClavier : in STD_LOGIC; HorlogeFiltree : out STD_LOGIC);
    end component;
    component detecteur_front
        port (GClock, GResetBar, Entree : in STD_LOGIC; FD : out STD_LOGIC);
    end component;
    component synchroniseur
        port (GClock, GResetBar, Entree : in STD_LOGIC; Sortie : out STD_LOGIC);
    end component;
    component fsm_controleur
        port (
            GClock, GResetBar, FD, Info, Fin : in STD_LOGIC;
            RAZ, Charge, Decale : out STD_LOGIC;
            Etat : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    component compteur4bit
        port (
            GClock, GResetBar, RAZ, Decale : in STD_LOGIC;
            Fin : out STD_LOGIC;
            Valeur : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    component registre_decalage
        port (
            GClock, GResetBar, Decale, Info : in STD_LOGIC;
            Trame : out STD_LOGIC_VECTOR(9 downto 0);
            Octet : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    component registre8
        port (
            GClock, GResetBar, Charge : in STD_LOGIC;
            D : in STD_LOGIC_VECTOR(7 downto 0);
            Q : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    component afficheur7seg
        generic (DIV_MAX : natural);
        port (
            GClock, GResetBar : in STD_LOGIC;
            Octet : in STD_LOGIC_VECTOR(7 downto 0);
            SEG : out STD_LOGIC_VECTOR(6 downto 0);
            DP : out STD_LOGIC;
            AN : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal HorlogeFiltree, FD, Info   : STD_LOGIC;
    signal RAZ, Charge, Decale, Fin   : STD_LOGIC;
    signal Etat                       : STD_LOGIC_VECTOR(1 downto 0);
    signal Compte                     : STD_LOGIC_VECTOR(3 downto 0);
    signal Trame                      : STD_LOGIC_VECTOR(9 downto 0);
    signal OctetRecu, OctetAffiche    : STD_LOGIC_VECTOR(7 downto 0);

begin

    FILTRE : filtre_digitale port map (GClock => HorlogeG, GResetBar => ResetG,
                                       HorlogeClavier => HorlogeClavier, HorlogeFiltree => HorlogeFiltree);
    FRONT  : detecteur_front port map (GClock => HorlogeG, GResetBar => ResetG,
                                       Entree => HorlogeFiltree, FD => FD);
    SYNC   : synchroniseur port map (GClock => HorlogeG, GResetBar => ResetG,
                                     Entree => InfoClavier, Sortie => Info);

    FSM    : fsm_controleur port map (GClock => HorlogeG, GResetBar => ResetG, FD => FD,
                                      Info => Info, Fin => Fin, RAZ => RAZ, Charge => Charge,
                                      Decale => Decale, Etat => Etat);
    CPT    : compteur4bit port map (GClock => HorlogeG, GResetBar => ResetG, RAZ => RAZ,
                                    Decale => Decale, Fin => Fin, Valeur => Compte);

    DECAL  : registre_decalage port map (GClock => HorlogeG, GResetBar => ResetG, Decale => Decale,
                                         Info => Info, Trame => Trame, Octet => OctetRecu);
    REGAFF : registre8 port map (GClock => HorlogeG, GResetBar => ResetG, Charge => Charge,
                                 D => OctetRecu, Q => OctetAffiche);

    AFF    : afficheur7seg generic map (DIV_MAX => DIV_MAX)
                           port map (GClock => HorlogeG, GResetBar => ResetG, Octet => OctetAffiche,
                                     SEG => SEG, DP => DP, AN => AN);

    BCD1 <= OctetAffiche(7 downto 4);
    BCD2 <= OctetAffiche(3 downto 0);

end structurel;
