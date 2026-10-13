-- Banc d'essai auto-verifiant de l'unite d'addition/soustraction 4 bits.
-- Applique 9 cas (un toutes les 10 ns) et compare S, CarryOut,
-- OverflowOut et ZeroOut aux valeurs theoriques calculees a la main.
-- Les signaux A_dec, B_dec et S_dec montrent les valeurs en decimal
-- signe dans la forme d'onde.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_addsub4 is
end tb_addsub4;

architecture test of tb_addsub4 is

    component addsub4
        port (
            A, B        : in  STD_LOGIC_VECTOR(3 downto 0);
            AddSub      : in  STD_LOGIC;
            S           : out STD_LOGIC_VECTOR(3 downto 0);
            CarryOut    : out STD_LOGIC;
            OverflowOut : out STD_LOGIC;
            ZeroOut     : out STD_LOGIC
        );
    end component;

    signal A, B, S                   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal AddSub                    : STD_LOGIC := '0';
    signal CarryOut, OverflowOut, ZeroOut : STD_LOGIC;

    -- Lecture en decimal signe pour la forme d'onde
    signal A_dec, B_dec, S_dec : integer;

    -- Un cas de test : operandes, operation et resultats attendus
    type cas_t is record
        a, b   : integer;
        op     : STD_LOGIC;     -- '0' = addition, '1' = soustraction
        s      : integer;       -- resultat attendu (4 bits signe)
        c, v, z : STD_LOGIC;    -- CarryOut, OverflowOut, ZeroOut attendus
    end record;
    type cas_tab is array (natural range <>) of cas_t;

    constant CAS : cas_tab := (
    --    a   b   op    s    C    V    Z
        ( 3,  2, '0',  5, '0', '0', '0'),  -- 1 : addition normale
        (-3,  5, '0',  2, '1', '0', '0'),  -- 2 : retenue ignoree en signe
        ( 5,  4, '0', -7, '0', '1', '0'),  -- 3 : debordement positif
        (-5, -4, '0',  7, '1', '1', '0'),  -- 4 : debordement negatif
        ( 6,  2, '1',  4, '1', '0', '0'),  -- 5 : soustraction normale
        ( 2,  5, '1', -3, '0', '0', '0'),  -- 6 : resultat negatif (emprunt, c4 = 0)
        ( 7, -1, '1', -8, '0', '1', '0'),  -- 7 : debordement en soustraction
        ( 0, -8, '1', -8, '0', '1', '0'),  -- 8 : -(-8) n'existe pas sur 4 bits
        ( 4,  4, '1',  0, '1', '0', '1')   -- 9 : drapeau zero
    );

begin

    UUT : addsub4 port map (
        A => A, B => B, AddSub => AddSub, S => S,
        CarryOut => CarryOut, OverflowOut => OverflowOut, ZeroOut => ZeroOut
    );

    A_dec <= to_integer(signed(A));
    B_dec <= to_integer(signed(B));
    S_dec <= to_integer(signed(S));

    stimulus : process
        variable erreurs : integer := 0;
    begin
        for i in CAS'range loop
            A      <= std_logic_vector(to_signed(CAS(i).a, 4));
            B      <= std_logic_vector(to_signed(CAS(i).b, 4));
            AddSub <= CAS(i).op;
            wait for 10 ns;

            if to_integer(signed(S)) /= CAS(i).s or CarryOut /= CAS(i).c
               or OverflowOut /= CAS(i).v or ZeroOut /= CAS(i).z then
                erreurs := erreurs + 1;
                report "ERREUR cas " & integer'image(i + 1) &
                       " : S = " & integer'image(to_integer(signed(S))) &
                       ", attendu " & integer'image(CAS(i).s)
                    severity error;
            end if;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
