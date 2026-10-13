-- Banc d'essai auto-verifiant du diviseur signe.
-- Partie 1 : 5 exemples choisis (lisibles dans la forme d'onde, 0 a ~600 ns).
-- Partie 2 : les 256 paires (A, B) de -8..7.
--   - cas valides : Quotient et Reste compares a la division tronquee,
--     Ovf doit valoir 0 ;
--   - division par zero et -8 / -1 : Ovf doit valoir 1.
-- On verifie aussi que Done arrive exactement au 10e front de GClock.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_diviseur is
end tb_diviseur;

architecture test of tb_diviseur is

    component diviseur
        port (
            GClock, GReset     : in  STD_LOGIC;
            OperandA, OperandB : in  STD_LOGIC_VECTOR(3 downto 0);
            Quotient, Reste    : out STD_LOGIC_VECTOR(3 downto 0);
            Ovf, Done          : out STD_LOGIC
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock, GReset : STD_LOGIC := '0';
    signal OperandA, OperandB : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal Quotient, Reste : STD_LOGIC_VECTOR(3 downto 0);
    signal Ovf, Done : STD_LOGIC;

    -- Lecture en decimal signe pour la forme d'onde
    signal A_dec, B_dec, Q_dec, R_dec : integer;

    type paire_t is array (0 to 1) of integer;
    type paires_t is array (natural range <>) of paire_t;
    constant EXEMPLES : paires_t := (
        ( 7,  2),   -- Q =  3, R =  1
        (-7,  2),   -- Q = -3, R = -1
        ( 7, -2),   -- Q = -3, R =  1
        (-7, -2),   -- Q =  3, R = -1
        (-8,  3)    -- Q = -2, R = -2
    );

begin

    UUT : diviseur port map (
        GClock => GClock, GReset => GReset, OperandA => OperandA, OperandB => OperandB,
        Quotient => Quotient, Reste => Reste, Ovf => Ovf, Done => Done
    );

    A_dec <= to_integer(signed(OperandA));
    B_dec <= to_integer(signed(OperandB));
    Q_dec <= to_integer(signed(Quotient));
    R_dec <= to_integer(signed(Reste));

    stimulus : process
        variable erreurs : integer := 0;
        variable fronts  : integer;
        variable q_att, r_att : integer;
        variable special : boolean;

        -- Lance une division a / b et verifie le resultat
        procedure diviser (a, b : integer) is
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

            special := (b = 0) or (a = -8 and b = -1);
            if special then
                if Ovf /= '1' or fronts /= 10 then
                    erreurs := erreurs + 1;
                    report "ERREUR : " & integer'image(a) & " / " & integer'image(b) &
                           " devrait donner Ovf = 1" severity error;
                end if;
            else
                -- Division tronquee vers zero : reste du signe du dividende
                q_att := abs(a) / abs(b);
                if (a < 0) /= (b < 0) then
                    q_att := -q_att;
                end if;
                r_att := a - q_att * b;
                if to_integer(signed(Quotient)) /= q_att or to_integer(signed(Reste)) /= r_att
                   or Ovf /= '0' or fronts /= 10 then
                    erreurs := erreurs + 1;
                    report "ERREUR : " & integer'image(a) & " / " & integer'image(b) &
                           " -> Q = " & integer'image(to_integer(signed(Quotient))) &
                           ", R = " & integer'image(to_integer(signed(Reste))) &
                           " (attendu Q = " & integer'image(q_att) &
                           ", R = " & integer'image(r_att) & ")" severity error;
                end if;
            end if;
            wait for PERIODE;
        end procedure;

    begin
        -- Partie 1 : exemples choisis
        for i in EXEMPLES'range loop
            diviser(EXEMPLES(i)(0), EXEMPLES(i)(1));
        end loop;

        -- Partie 2 : les 256 paires
        for a in -8 to 7 loop
            for b in -8 to 7 loop
                diviser(a, b);
            end loop;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s) sur " &
               integer'image(EXEMPLES'length + 256) & " divisions";
        wait;
    end process;

end test;
