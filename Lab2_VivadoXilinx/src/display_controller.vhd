-- Controleur de l'afficheur sept segments multiplexe de la Nexys A7.
-- (Seul bloc ecrit de maniere comportementale, comme le permet l'enonce :
--  c'est de la colle propre a la carte, pas une partie de l'ALU.)
-- Affiche valeur[7..0] en hexadecimal sur deux chiffres :
--   AN1 = quartet haut valeur[7..4], AN0 = quartet bas valeur[3..0].
-- Les 8 chiffres partagent les cathodes : un compteur libre a 100 MHz
-- alterne le chiffre actif. Bit 16 du compteur -> ~763 Hz par chiffre,
-- sans scintillement. Anodes et cathodes actives a l'etat bas.
-- seg(6) = CA (a), seg(5) = CB (b), ..., seg(0) = CG (g).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_controller is
    port (
        CLK100MHZ : in  STD_LOGIC;
        valeur    : in  STD_LOGIC_VECTOR(7 downto 0);
        seg       : out STD_LOGIC_VECTOR(6 downto 0);
        an        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end display_controller;

architecture comportemental of display_controller is

    signal compteur : unsigned(16 downto 0) := (others => '0');
    signal quartet  : STD_LOGIC_VECTOR(3 downto 0);
    signal abcdefg  : STD_LOGIC_VECTOR(6 downto 0);   -- actif a l'etat haut

begin

    -- Compteur de rafraichissement libre
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            compteur <= compteur + 1;
        end if;
    end process;

    -- Choix du chiffre actif et du quartet a afficher
    process(compteur, valeur)
    begin
        if compteur(16) = '0' then
            an      <= "11111110";            -- AN0 : quartet bas
            quartet <= valeur(3 downto 0);
        else
            an      <= "11111101";            -- AN1 : quartet haut
            quartet <= valeur(7 downto 4);
        end if;
    end process;

    -- Decodeur hexadecimal vers segments (a b c d e f g)
    process(quartet)
    begin
        case quartet is
            when "0000" => abcdefg <= "1111110";  -- 0
            when "0001" => abcdefg <= "0110000";  -- 1
            when "0010" => abcdefg <= "1101101";  -- 2
            when "0011" => abcdefg <= "1111001";  -- 3
            when "0100" => abcdefg <= "0110011";  -- 4
            when "0101" => abcdefg <= "1011011";  -- 5
            when "0110" => abcdefg <= "1011111";  -- 6
            when "0111" => abcdefg <= "1110000";  -- 7
            when "1000" => abcdefg <= "1111111";  -- 8
            when "1001" => abcdefg <= "1111011";  -- 9
            when "1010" => abcdefg <= "1110111";  -- A
            when "1011" => abcdefg <= "0011111";  -- b
            when "1100" => abcdefg <= "1001110";  -- C
            when "1101" => abcdefg <= "0111101";  -- d
            when "1110" => abcdefg <= "1001111";  -- E
            when others => abcdefg <= "1000111";  -- F
        end case;
    end process;

    -- Cathodes actives a l'etat bas
    seg <= not abcdefg;

end comportemental;
