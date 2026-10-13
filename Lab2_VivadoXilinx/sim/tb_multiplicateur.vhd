-- Banc d'essai auto-verifiant du multiplicateur signe.
-- Partie 1 : 5 exemples choisis (lisibles dans la forme d'onde, 0 a ~600 ns).
-- Partie 2 : les 256 paires (A, B) de -8..7, comparees a A x B.
-- Pour chaque calcul : impulsion GReset, puis fronts de GClock jusqu'a Done.
-- On verifie aussi que Done arrive exactement au 10e front.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_multiplicateur is
end tb_multiplicateur;

architecture test of tb_multiplicateur is

    component multiplicateur
        port (
            GClock, GReset     : in  STD_LOGIC;
            OperandA, OperandB : in  STD_LOGIC_VECTOR(3 downto 0);
            Produit            : out STD_LOGIC_VECTOR(7 downto 0);
            Done               : out STD_LOGIC
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock, GReset : STD_LOGIC := '0';
    signal OperandA, OperandB : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal Produit : STD_LOGIC_VECTOR(7 downto 0);
    signal Done    : STD_LOGIC;

    -- Lecture en decimal signe pour la forme d'onde
    signal A_dec, B_dec, P_dec : integer;

    type paire_t is array (0 to 1) of integer;
    type paires_t is array (natural range <>) of paire_t;
    constant EXEMPLES : paires_t := (
        ( 2, -3),   -- multiplicateur negatif : soustraction au dernier bit
        ( 3,  2),   -- deux positifs
        (-5,  2),   -- multiplicande negatif
        (-8, -8),   -- le plus grand produit : +64
        ( 7, -8)    -- le plus petit produit : -56
    );

begin

    UUT : multiplicateur port map (
        GClock => GClock, GReset => GReset, OperandA => OperandA, OperandB => OperandB,
        Produit => Produit, Done => Done
    );

    A_dec <= to_integer(signed(OperandA));
    B_dec <= to_integer(signed(OperandB));
    P_dec <= to_integer(signed(Produit));

    stimulus : process
        variable erreurs : integer := 0;
        variable fronts  : integer;

        -- Lance une multiplication a x b et verifie le resultat
        procedure multiplier (a, b : integer) is
        begin
            OperandA <= std_logic_vector(to_signed(a, 4));
            OperandB <= std_logic_vector(to_signed(b, 4));
            GReset   <= '1';
            wait for PERIODE;
            GReset   <= '0';
            fronts   := 0;
            while Done = '0' and fronts < 20 loop
                GClock <= '1'; wait for PERIODE / 2;
                GClock <= '0'; wait for PERIODE / 2;
                fronts := fronts + 1;
            end loop;
            if to_integer(signed(Produit)) /= a * b or fronts /= 10 then
                erreurs := erreurs + 1;
                report "ERREUR : " & integer'image(a) & " x " & integer'image(b) &
                       " = " & integer'image(to_integer(signed(Produit))) &
                       " (attendu " & integer'image(a * b) & "), Done apres " &
                       integer'image(fronts) & " fronts"
                    severity error;
            end if;
            wait for PERIODE;
        end procedure;

    begin
        -- Partie 1 : exemples choisis
        for i in EXEMPLES'range loop
            multiplier(EXEMPLES(i)(0), EXEMPLES(i)(1));
        end loop;

        -- Partie 2 : les 256 paires
        for a in -8 to 7 loop
            for b in -8 to 7 loop
                multiplier(a, b);
            end loop;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s) sur " &
               integer'image(EXEMPLES'length + 256) & " multiplications";
        wait;
    end process;

end test;
