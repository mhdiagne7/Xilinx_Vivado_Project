-- Chemin de donnees du diviseur signe 4 bits (quotient tronque vers zero,
-- reste du meme signe que le dividende).
-- Registres : R (8 bits, reste), Div (8 bits, diviseur x 2^i), Q (4 bits),
--             Compteur C (3 bits), sD (1 bit, signe du dividende).
--   Mux R : selR = 0 -> OperandA etendu,   1 -> T
--   Mux D : selD = 0 -> OperandB x 8,      1 -> ASR(Div)
--   Mux Q : selQ = 0 -> 0000,              1 -> 2Q +/- Acc
--   Mux C : selC = 0 -> 100 (4),           1 -> C - 1
-- Meme = (sD = signe de Div) : 1 -> T = R - Div et Q <- 2Q + Acc
--                              0 -> T = R + Div et Q <- 2Q - Acc
-- Acc  = l'essai T n'a pas traverse zero : T(7) = sD ou T = 0
-- Ovf  = division par zero ou quotient hors plage (-8 / -1)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity div_datapath is
    port (
        GClock, GReset : in  STD_LOGIC;
        OperandA       : in  STD_LOGIC_VECTOR(3 downto 0);   -- dividende
        OperandB       : in  STD_LOGIC_VECTOR(3 downto 0);   -- diviseur
        -- signaux de commande
        loadR, selR, loadD, selD, loadQ, selQ, loadC, selC, loadS : in STD_LOGIC;
        -- signaux d'etat
        Acc, Z0        : out STD_LOGIC;
        -- resultats
        Quotient       : out STD_LOGIC_VECTOR(3 downto 0);
        Reste          : out STD_LOGIC_VECTOR(3 downto 0);
        Ovf            : out STD_LOGIC
    );
end div_datapath;

architecture structurel of div_datapath is

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
    constant ZERO4  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant QUATRE : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant MOINS1 : STD_LOGIC_VECTOR(2 downto 0) := "111";

    -- Sorties des registres
    signal R, Div : STD_LOGIC_VECTOR(7 downto 0);
    signal Q      : STD_LOGIC_VECTOR(3 downto 0);
    signal C      : STD_LOGIC_VECTOR(2 downto 0);
    signal sD     : STD_LOGIC_VECTOR(0 downto 0);

    -- Valeurs calculees
    signal A_ext, B_x8, T, Div_asr, R_next, Div_next : STD_LOGIC_VECTOR(7 downto 0);
    signal Q_x2, Acc_v, Q_plus, Q_next               : STD_LOGIC_VECTOR(3 downto 0);
    signal C_moins1, C_next                          : STD_LOGIC_VECTOR(2 downto 0);
    signal Meme, nMeme, Tz, Acc_i, Bz                : STD_LOGIC;

begin

    -- Registre R : reste partiel, part du dividende etendu a 8 bits
    A_ext <= OperandA(3) & OperandA(3) & OperandA(3) & OperandA(3) & OperandA;
    MUX_R : mux2N generic map (N => 8)
                  port map (sel => selR, D0 => A_ext, D1 => T, Y => R_next);
    REG_R : registreN generic map (N => 8)
                      port map (clk => GClock, reset => GReset, load => loadR, D => R_next, Q => R);

    -- Registre Div : diviseur x 8 au depart, puis divise par 2 (decalage arithmetique)
    B_x8    <= OperandB(3) & OperandB & "000";
    Div_asr <= Div(7) & Div(7 downto 1);
    MUX_D : mux2N generic map (N => 8)
                  port map (sel => selD, D0 => B_x8, D1 => Div_asr, Y => Div_next);
    REG_D : registreN generic map (N => 8)
                      port map (clk => GClock, reset => GReset, load => loadD, D => Div_next, Q => Div);

    -- Registre sD : signe du dividende, garde pendant tout le calcul
    REG_S : registreN generic map (N => 1)
                      port map (clk => GClock, reset => GReset, load => loadS, D => OperandA(3 downto 3), Q => sD);

    -- Meme = 1 si le dividende et le diviseur ont le meme signe (XNOR)
    Meme  <= not (sD(0) xor Div(7));
    nMeme <= not Meme;

    -- Essai : T = R - Div (meme signe) ou R + Div (signes differents)
    ADD_R : addsubN generic map (N => 8)
                    port map (A => R, B => Div, AddSub => Meme, S => T,
                              CarryOut => open, OverflowOut => open, ZeroOut => Tz);

    -- Acceptation : T est du meme cote de zero que le dividende, ou T = 0
    Acc_i <= (not (T(7) xor sD(0))) or Tz;
    Acc   <= Acc_i;

    -- Quotient : Q <- 2Q + Acc (meme signe) ou 2Q - Acc (signes differents)
    Q_x2  <= Q(2 downto 0) & '0';
    Acc_v <= "000" & Acc_i;
    ADD_Q : addsubN generic map (N => 4)
                    port map (A => Q_x2, B => Acc_v, AddSub => nMeme, S => Q_plus,
                              CarryOut => open, OverflowOut => open, ZeroOut => open);
    MUX_Q : mux2N generic map (N => 4)
                  port map (sel => selQ, D0 => ZERO4, D1 => Q_plus, Y => Q_next);
    REG_Q : registreN generic map (N => 4)
                      port map (clk => GClock, reset => GReset, load => loadQ, D => Q_next, Q => Q);

    -- Compteur (identique au multiplicateur) : C + 111 = C - 1
    DEC : rcaN generic map (N => 3)
               port map (A => C, B => MOINS1, cin => '0', S => C_moins1, cn1 => open, cout => open);
    MUX_C : mux2N generic map (N => 3)
                  port map (sel => selC, D0 => QUATRE, D1 => C_moins1, Y => C_next);
    REG_C : registreN generic map (N => 3)
                      port map (clk => GClock, reset => GReset, load => loadC, D => C_next, Q => C);
    Z0 <= not (C(2) or C(1) or C(0));

    -- Debordement : diviseur nul (teste sur l'entree, Div est decale a la fin)
    -- ou meme signe avec un quotient "negatif" (seul cas : -8 / -1 = +8)
    Bz  <= not (OperandB(3) or OperandB(2) or OperandB(1) or OperandB(0));
    Ovf <= Bz or (Meme and Q(3));

    Quotient <= Q;
    Reste    <= R(3 downto 0);

end structurel;
