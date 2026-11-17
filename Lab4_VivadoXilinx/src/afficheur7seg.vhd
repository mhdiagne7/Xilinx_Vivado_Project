-- Afficheur 7 segments multiplexe : affiche un octet en hexadecimal sur deux
-- chiffres de la Nexys A7, structurel.
--   AN1 (chiffre de gauche)  : 4 bits du haut, Octet(7..4) = BCD1
--   AN0 (chiffre de droite)  : 4 bits du bas,  Octet(3..0) = BCD2
-- Les 8 chiffres partagent les cathodes : une bascule change de chiffre a
-- chaque impulsion Tick du diviseur de rafraichissement (validation
-- d'horloge, D = Q') ; un multiplexeur choisit les 4 bits a decoder et le
-- decodeur dec_7seg du cours (0 a F) pilote les cathodes.
-- Anodes, cathodes et point decimal actifs a l'etat bas ; AN7..AN2 et DP eteints.
-- Ordre des cathodes (tableau 4) : SEG(0) = CA ... SEG(6) = CG.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity afficheur7seg is
    generic (DIV_MAX : natural := 49999);
    port (
        GClock    : in  STD_LOGIC;                     -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;                     -- reset global, actif a 0
        Octet     : in  STD_LOGIC_VECTOR(7 downto 0);  -- valeur a afficher
        SEG       : out STD_LOGIC_VECTOR(6 downto 0);
        DP        : out STD_LOGIC;
        AN        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end afficheur7seg;

architecture structurel of afficheur7seg is

    component diviseur_rafraichissement
        generic (DIV_MAX : natural);
        port (GClock, GResetBar : in STD_LOGIC; Tick : out STD_LOGIC);
    end component;

    component dec_7seg
        port (
            i_hexDigit : in STD_LOGIC_VECTOR(3 downto 0);
            o_segment_a, o_segment_b, o_segment_c, o_segment_d, o_segment_e,
            o_segment_f, o_segment_g : out STD_LOGIC
        );
    end component;

    component enARdFF_2
        port (
            i_resetBar  : in  STD_LOGIC;
            i_d         : in  STD_LOGIC;
            i_enable    : in  STD_LOGIC;
            i_clock     : in  STD_LOGIC;
            o_q, o_qBar : out STD_LOGIC
        );
    end component;

    signal Tick      : STD_LOGIC;
    signal sel, selb : STD_LOGIC;   -- 0 = chiffre de droite (AN0), 1 = gauche (AN1)
    signal chiffre   : STD_LOGIC_VECTOR(3 downto 0);

begin

    DIV : diviseur_rafraichissement generic map (DIV_MAX => DIV_MAX)
                                    port map (GClock => GClock, GResetBar => GResetBar, Tick => Tick);

    -- Bascule qui alterne entre les deux chiffres a chaque Tick
    BASC : enARdFF_2 port map (i_resetBar => GResetBar, i_d => selb, i_enable => Tick,
                               i_clock => GClock, o_q => sel, o_qBar => selb);

    -- Multiplexeur : 4 bits du bas (droite) ou du haut (gauche)
    BITS : for i in 0 to 3 generate
        chiffre(i) <= (Octet(i) and selb) or (Octet(i + 4) and sel);
    end generate;

    DEC : dec_7seg port map (i_hexDigit => chiffre,
                             o_segment_a => SEG(0), o_segment_b => SEG(1), o_segment_c => SEG(2),
                             o_segment_d => SEG(3), o_segment_e => SEG(4), o_segment_f => SEG(5),
                             o_segment_g => SEG(6));

    AN(0) <= sel;                   -- allume quand sel = 0
    AN(1) <= selb;                  -- allume quand sel = 1
    AN(7 downto 2) <= (others => '1');
    DP <= '1';

end structurel;
