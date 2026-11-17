-- Diviseur de rafraichissement de l'afficheur (section 8.2 de l'enonce).
-- Seul bloc comportemental du laboratoire (permis pour les diviseurs
-- d'horloge, section 9). Il ne cree pas de nouvelle horloge : il produit une
-- validation d'horloge Tick = 1 pendant un seul cycle toutes les DIV_MAX + 1
-- periodes de 100 MHz. Avec DIV_MAX = 49999 : Tick a 2 kHz, donc chaque
-- chiffre est rafraichi a 1 kHz (deux chiffres en alternance).
-- DIV_MAX est un generique pour pouvoir simuler avec une petite valeur.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity diviseur_rafraichissement is
    generic (DIV_MAX : natural := 49999);
    port (
        GClock    : in  STD_LOGIC;   -- horloge globale 100 MHz
        GResetBar : in  STD_LOGIC;   -- reset global, actif a 0
        Tick      : out STD_LOGIC    -- impulsion d'un cycle a 100 MHz / (DIV_MAX + 1)
    );
end diviseur_rafraichissement;

architecture comportemental of diviseur_rafraichissement is
    signal compte : natural range 0 to DIV_MAX := 0;
begin

    process (GClock, GResetBar)
    begin
        if GResetBar = '0' then
            compte <= 0;
        elsif rising_edge(GClock) then
            if compte = DIV_MAX then
                compte <= 0;
            else
                compte <= compte + 1;
            end if;
        end if;
    end process;

    Tick <= '1' when compte = DIV_MAX else '0';

end comportemental;
