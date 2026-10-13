-- Banc d'essai auto-verifiant de l'ALU complete (alu_top).
-- Partie 1 : un exemple par operation (lisible dans la forme d'onde).
-- Partie 2 : les 256 paires (A, B) pour chacune des 4 operations :
--   00 / 01 : MuxOut, CarryOut, OverflowOut, ZeroOut (resultat immediat)
--   10 / 11 : GReset puis 10 fronts de GClock, puis MuxOut et les signaux d'etat
-- CLK100MHZ tourne en continu (afficheur), il n'influence pas les resultats.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu_top is
end tb_alu_top;

architecture test of tb_alu_top is

    component alu_top
        port (
            GClock, GReset, CLK100MHZ : in  STD_LOGIC;
            OperandA, OperandB        : in  STD_LOGIC_VECTOR(3 downto 0);
            OperationSelect           : in  STD_LOGIC_VECTOR(1 downto 0);
            MuxOut                    : out STD_LOGIC_VECTOR(7 downto 0);
            CarryOut, ZeroOut, OverflowOut : out STD_LOGIC;
            seg                       : out STD_LOGIC_VECTOR(6 downto 0);
            an                        : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock, GReset, CLK100MHZ : STD_LOGIC := '0';
    signal OperandA, OperandB : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal OperationSelect    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal MuxOut             : STD_LOGIC_VECTOR(7 downto 0);
    signal CarryOut, ZeroOut, OverflowOut : STD_LOGIC;
    signal seg : STD_LOGIC_VECTOR(6 downto 0);
    signal an  : STD_LOGIC_VECTOR(7 downto 0);
    signal fin : boolean := false;

    -- Lecture en decimal signe pour la forme d'onde
    signal A_dec, B_dec : integer;

begin

    UUT : alu_top port map (
        GClock => GClock, GReset => GReset, CLK100MHZ => CLK100MHZ,
        OperandA => OperandA, OperandB => OperandB, OperationSelect => OperationSelect,
        MuxOut => MuxOut, CarryOut => CarryOut, ZeroOut => ZeroOut, OverflowOut => OverflowOut,
        seg => seg, an => an
    );

    A_dec <= to_integer(signed(OperandA));
    B_dec <= to_integer(signed(OperandB));

    -- Oscillateur 100 MHz de la carte
    CLK100MHZ <= not CLK100MHZ after 5 ns when not fin else '0';

    stimulus : process
        variable erreurs : integer := 0;
        variable r, q, rr : integer;
        variable att      : STD_LOGIC_VECTOR(7 downto 0);
        variable c_att, v_att : STD_LOGIC;

        -- GReset puis 10 fronts de GClock (unites sequentielles)
        procedure dix_fronts is
        begin
            GReset <= '1'; wait for PERIODE; GReset <= '0';
            for k in 1 to 10 loop
                GClock <= '1'; wait for PERIODE / 2;
                GClock <= '0'; wait for PERIODE / 2;
            end loop;
        end procedure;

        procedure verifier (a, b : integer; op : STD_LOGIC_VECTOR(1 downto 0)) is
        begin
            OperandA <= std_logic_vector(to_signed(a, 4));
            OperandB <= std_logic_vector(to_signed(b, 4));
            OperationSelect <= op;
            c_att := '0';
            v_att := '0';
            case op is
                when "00" | "01" =>
                    if op = "00" then r := a + b; else r := a - b; end if;
                    att := "0000" & std_logic_vector(to_signed(r mod 16, 5)(3 downto 0));
                    if op = "00" then
                        if (a mod 16) + (b mod 16) > 15 then c_att := '1'; end if;
                    else
                        if (a mod 16) >= (b mod 16) then c_att := '1'; end if;
                    end if;
                    if r < -8 or r > 7 then v_att := '1'; end if;
                    wait for PERIODE;
                when "10" =>
                    att := std_logic_vector(to_signed(a * b, 8));
                    dix_fronts;
                when others =>
                    if b = 0 or (a = -8 and b = -1) then
                        v_att := '1';
                    else
                        q := abs(a) / abs(b);
                        if (a < 0) /= (b < 0) then q := -q; end if;
                        rr := a - q * b;
                        att := std_logic_vector(to_signed(rr, 4)) & std_logic_vector(to_signed(q, 4));
                    end if;
                    dix_fronts;
            end case;
            if (v_att = '0' and MuxOut /= att) or CarryOut /= c_att or OverflowOut /= v_att
               or (v_att = '0' and ((ZeroOut = '1') /= (att = "00000000"))) then
                erreurs := erreurs + 1;
                report "ERREUR : op " & integer'image(to_integer(unsigned(op))) &
                       ", A = " & integer'image(a) & ", B = " & integer'image(b) severity error;
            end if;
            wait for PERIODE;
        end procedure;

    begin
        -- Partie 1 : un exemple par operation
        verifier( 5, -3, "00");   --  5 + (-3) = 2
        verifier( 5, -3, "01");   --  5 - (-3) = 8 -> debordement
        verifier( 2, -3, "10");   --  2 x (-3) = -6
        verifier(-7,  2, "11");   -- -7 / 2 : Q = -3, R = -1

        -- Partie 2 : les 4 operations sur les 256 paires
        for op in 0 to 3 loop
            for a in -8 to 7 loop
                for b in -8 to 7 loop
                    verifier(a, b, std_logic_vector(to_unsigned(op, 2)));
                end loop;
            end loop;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s) sur " &
               integer'image(4 + 4 * 256) & " operations";
        fin <= true;
        wait;
    end process;

end test;
