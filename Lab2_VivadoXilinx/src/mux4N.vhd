-- Multiplexeur 4 vers 1 sur N bits, construit avec trois mux2N en arbre.
--   sel = "00" : Y = D0      sel = "10" : Y = D2
--   sel = "01" : Y = D1      sel = "11" : Y = D3
-- Premier niveau (sel(0)) : D0/D1 et D2/D3 ; second niveau (sel(1)) : choix final.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4N is
    generic ( N : positive := 4 );
    port (
        sel            : in  STD_LOGIC_VECTOR(1 downto 0);
        D0, D1, D2, D3 : in  STD_LOGIC_VECTOR(N-1 downto 0);
        Y              : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
end mux4N;

architecture structurel of mux4N is

    component mux2N
        generic ( N : positive );
        port (
            sel    : in  STD_LOGIC;
            D0, D1 : in  STD_LOGIC_VECTOR(N-1 downto 0);
            Y      : out STD_LOGIC_VECTOR(N-1 downto 0)
        );
    end component;

    signal Y01, Y23 : STD_LOGIC_VECTOR(N-1 downto 0);

begin

    M01 : mux2N generic map (N => N) port map (sel => sel(0), D0 => D0,  D1 => D1,  Y => Y01);
    M23 : mux2N generic map (N => N) port map (sel => sel(0), D0 => D2,  D1 => D3,  Y => Y23);
    MF  : mux2N generic map (N => N) port map (sel => sel(1), D0 => Y01, D1 => Y23, Y => Y);

end structurel;
