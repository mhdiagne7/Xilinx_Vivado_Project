-- Affichage du compteur en decimal sur deux chiffres (bonus), en structurel.
-- Les 8 chiffres de la Nexys A7 partagent les cathodes : on alterne entre
-- AN0 (unites) et AN1 (dizaines) a chaque front de l'horloge 1 kHz du
-- diviseur (500 Hz par chiffre, sans scintillement). Les autres chiffres
-- restent eteints. Anodes et cathodes actives a l'etat bas.
-- Decodeur : dec_7seg fourni par le cours.
-- Ordre des cathodes (tableau 10) : SEG(0) = CA ... SEG(6) = CG.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity affichage is
    port (
        Clk1kHz   : in  STD_LOGIC;                     -- rafraichissement
        GResetBar : in  STD_LOGIC;
        Valeur    : in  STD_LOGIC_VECTOR(3 downto 0);  -- 0 a 15
        SEG       : out STD_LOGIC_VECTOR(6 downto 0);
        AN        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end affichage;

architecture structurel of affichage is

    component bin_bcd
        port (
            v                : in  STD_LOGIC_VECTOR(3 downto 0);
            dizaines, unites : out STD_LOGIC_VECTOR(3 downto 0)
        );
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

    signal diz, uni, chiffre : STD_LOGIC_VECTOR(3 downto 0);
    signal sel, selb         : STD_LOGIC;   -- 0 = unites (AN0), 1 = dizaines (AN1)

begin

    CONV : bin_bcd port map (v => Valeur, dizaines => diz, unites => uni);

    -- Bascule qui change de chiffre a chaque front 1 kHz (D = Q')
    BASC : enARdFF_2 port map (i_resetBar => GResetBar, i_d => selb, i_enable => '1',
                               i_clock => Clk1kHz, o_q => sel, o_qBar => selb);

    -- Multiplexeur : chiffre a afficher
    BITS : for i in 0 to 3 generate
        chiffre(i) <= (uni(i) and selb) or (diz(i) and sel);
    end generate;

    DEC : dec_7seg port map (i_hexDigit => chiffre,
                             o_segment_a => SEG(0), o_segment_b => SEG(1), o_segment_c => SEG(2),
                             o_segment_d => SEG(3), o_segment_e => SEG(4), o_segment_f => SEG(5),
                             o_segment_g => SEG(6));

    -- Anodes : AN0 pour les unites, AN1 pour les dizaines, les autres eteintes
    AN(0) <= sel;
    AN(1) <= selb;
    AN(7 downto 2) <= (others => '1');

end structurel;
