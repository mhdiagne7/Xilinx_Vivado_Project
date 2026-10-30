-- Banc d'essai auto-verifiant du diviseur d'horloge adapte (100 MHz).
-- Mesure la periode des sorties 1 MHz, 100 kHz, 10 kHz, 1 kHz et 100 Hz
-- (le 1 Hz demanderait 100 millions de cycles ; chaque etage suivant est
-- le meme diviseur par 10, et le 1 Hz se verifie directement sur la carte).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_clk_div is
end tb_clk_div;

architecture test of tb_clk_div is

    component clk_div
        port (
            clock_100Mhz : in  STD_LOGIC;
            clock_1MHz, clock_100KHz, clock_10KHz, clock_1KHz : out STD_LOGIC;
            clock_100Hz, clock_10Hz, clock_1Hz                : out STD_LOGIC
        );
    end component;

    signal clk100M : STD_LOGIC := '0';
    signal c1M, c100k, c10k, c1k, c100, c10, c1 : STD_LOGIC;
    signal fin : boolean := false;

    -- Mesure la periode d'un signal entre deux fronts montants (apres le 1er)
    procedure mesurer (signal s : in STD_LOGIC; attendu : time; nom : string;
                       variable erreurs : inout integer) is
        variable t0 : time;
    begin
        wait until rising_edge(s);
        wait until rising_edge(s); t0 := now;
        wait until rising_edge(s);
        if now - t0 /= attendu then
            erreurs := erreurs + 1;
            report "ERREUR : periode de " & nom & " = " & time'image(now - t0) severity error;
        else
            report nom & " : periode " & time'image(now - t0) & " OK";
        end if;
    end procedure;

begin

    UUT : clk_div port map (
        clock_100Mhz => clk100M, clock_1MHz => c1M, clock_100KHz => c100k,
        clock_10KHz => c10k, clock_1KHz => c1k, clock_100Hz => c100,
        clock_10Hz => c10, clock_1Hz => c1
    );

    -- Oscillateur 100 MHz de la carte
    clk100M <= not clk100M after 5 ns when not fin else '0';

    stimulus : process
        variable erreurs : integer := 0;
    begin
        mesurer(c1M,   1 us,  "1 MHz",   erreurs);
        mesurer(c100k, 10 us, "100 kHz", erreurs);
        mesurer(c10k,  100 us, "10 kHz", erreurs);
        mesurer(c1k,   1 ms,  "1 kHz",   erreurs);
        mesurer(c100,  10 ms, "100 Hz",  erreurs);
        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        fin <= true;
        wait;
    end process;

end test;
