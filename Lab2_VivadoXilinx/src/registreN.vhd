-- Registre N bits a chargement parallele, fait de N bascules D.
--   load = '1' : Q <= D au front montant de clk
--   load = '0' : Q garde sa valeur
--   reset      : Q <= 0 (asynchrone)
-- N est un parametre (generic) : le meme fichier sert pour 3, 4 et 5 bits.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registreN is
    generic ( N : positive := 4 );
    port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        load  : in  STD_LOGIC;
        D     : in  STD_LOGIC_VECTOR(N-1 downto 0);
        Q     : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
end registreN;

architecture structurel of registreN is

    component bascule_D_AR
        port ( clk, reset, en, D : in STD_LOGIC; Q : out STD_LOGIC );
    end component;

begin

    -- Une bascule par bit ; load sert de validation (en) commune
    BITS : for i in 0 to N-1 generate
        FF : bascule_D_AR port map (clk => clk, reset => reset, en => load, D => D(i), Q => Q(i));
    end generate;

end structurel;
