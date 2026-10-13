-- Chemin de donnees du multiplicateur signe 4 bits (decaler-additionner signe).
-- Registres : M (5 bits), A (5 bits), Q (4 bits), Compteur C (3 bits).
--   Mux A  : selA = 00 -> 00000, 01 -> A +/- M, 10 -> ASR(A)
--   Mux Q  : selQ = 0  -> OperandB, 1 -> A(0) & Q(3..1)
--   Mux C  : selC = 0  -> 100 (4), 1 -> C - 1
-- Signaux d'etat vers la commande : Q0 = Q(0), Z0 = (C = 0), Z1 = (C = 1).
-- Produit = A(3..0) & Q.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mult_datapath is
    port (
        GClock, GReset : in  STD_LOGIC;
        OperandA       : in  STD_LOGIC_VECTOR(3 downto 0);
        OperandB       : in  STD_LOGIC_VECTOR(3 downto 0);
        -- signaux de commande
        loadM, loadA, loadQ, loadC : in STD_LOGIC;
        selA           : in  STD_LOGIC_VECTOR(1 downto 0);
        selQ, selC     : in  STD_LOGIC;
        AddSub         : in  STD_LOGIC;
        -- signaux d'etat
        Q0, Z0, Z1     : out STD_LOGIC;
        Produit        : out STD_LOGIC_VECTOR(7 downto 0)
    );
end mult_datapath;

architecture structurel of mult_datapath is

    component registreN
        generic ( N : positive );
        port (
            clk, reset, load : in  STD_LOGIC;
            D : in  STD_LOGIC_VECTOR(N-1 downto 0);
            Q : out STD_LOGIC_VECTOR(N-1 downto 0)
        );
    end component;

    component mux2N
        generic ( N : positive );
        port (
            sel    : in  STD_LOGIC;
            D0, D1 : in  STD_LOGIC_VECTOR(N-1 downto 0);
            Y      : out STD_LOGIC_VECTOR(N-1 downto 0)
        );
    end component;

    component mux4N
        generic ( N : positive );
        port (
            sel            : in  STD_LOGIC_VECTOR(1 downto 0);
            D0, D1, D2, D3 : in  STD_LOGIC_VECTOR(N-1 downto 0);
            Y              : out STD_LOGIC_VECTOR(N-1 downto 0)
        );
    end component;

    component addsubN
        generic ( N : positive );
        port (
            A, B   : in  STD_LOGIC_VECTOR(N-1 downto 0);
            AddSub : in  STD_LOGIC;
            S      : out STD_LOGIC_VECTOR(N-1 downto 0);
            CarryOut, OverflowOut, ZeroOut : out STD_LOGIC
        );
    end component;

    component rcaN
        generic ( N : positive );
        port (
            A, B : in  STD_LOGIC_VECTOR(N-1 downto 0);
            cin  : in  STD_LOGIC;
            S    : out STD_LOGIC_VECTOR(N-1 downto 0);
            cn1, cout : out STD_LOGIC
        );
    end component;

    -- Constantes
    constant ZERO5  : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant QUATRE : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant MOINS1 : STD_LOGIC_VECTOR(2 downto 0) := "111";

    -- Sorties des registres
    signal M, A : STD_LOGIC_VECTOR(4 downto 0);
    signal Q    : STD_LOGIC_VECTOR(3 downto 0);
    signal C    : STD_LOGIC_VECTOR(2 downto 0);

    -- Entrees des registres et valeurs calculees
    signal M_ext, Somme, A_asr, A_next : STD_LOGIC_VECTOR(4 downto 0);
    signal Q_dec, Q_next               : STD_LOGIC_VECTOR(3 downto 0);
    signal C_moins1, C_next            : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- Registre M : OperandA etendu a 5 bits (bit de signe recopie)
    M_ext <= OperandA(3) & OperandA;
    REG_M : registreN generic map (N => 5)
                      port map (clk => GClock, reset => GReset, load => loadM, D => M_ext, Q => M);

    -- Additionneur/soustracteur 5 bits : A + M ou A - M
    ADD : addsubN generic map (N => 5)
                  port map (A => A, B => M, AddSub => AddSub, S => Somme,
                            CarryOut => open, OverflowOut => open, ZeroOut => open);

    -- Decalage arithmetique a droite de A : le bit de signe A(4) est recopie
    A_asr <= A(4) & A(4 downto 1);

    -- Mux A et registre A
    MUX_A : mux4N generic map (N => 5)
                  port map (sel => selA, D0 => ZERO5, D1 => Somme, D2 => A_asr, D3 => ZERO5, Y => A_next);
    REG_A : registreN generic map (N => 5)
                      port map (clk => GClock, reset => GReset, load => loadA, D => A_next, Q => A);

    -- Decalage de Q : le bit A(0) entre a gauche, Q(0) sort a droite
    Q_dec <= A(0) & Q(3 downto 1);

    -- Mux Q et registre Q
    MUX_Q : mux2N generic map (N => 4)
                  port map (sel => selQ, D0 => OperandB, D1 => Q_dec, Y => Q_next);
    REG_Q : registreN generic map (N => 4)
                      port map (clk => GClock, reset => GReset, load => loadQ, D => Q_next, Q => Q);

    -- Decrementeur : C + 111 = C - 1 (retenue ignoree)
    DEC : rcaN generic map (N => 3)
               port map (A => C, B => MOINS1, cin => '0', S => C_moins1, cn1 => open, cout => open);

    -- Mux C et compteur
    MUX_C : mux2N generic map (N => 3)
                  port map (sel => selC, D0 => QUATRE, D1 => C_moins1, Y => C_next);
    REG_C : registreN generic map (N => 3)
                      port map (clk => GClock, reset => GReset, load => loadC, D => C_next, Q => C);

    -- Signaux d'etat
    Q0 <= Q(0);
    Z0 <= not (C(2) or C(1) or C(0));
    Z1 <= (not C(2)) and (not C(1)) and C(0);

    -- Produit sur 8 bits
    Produit <= A(3 downto 0) & Q;

end structurel;
