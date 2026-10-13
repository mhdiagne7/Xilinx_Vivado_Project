-- ALU 4 bits a point-fixe signee (entite de niveau superieur, tableau 3).
--   OperationSelect = 00 : MuxOut = 0000 & (A + B)
--                     01 : MuxOut = 0000 & (A - B)
--                     10 : MuxOut = produit A x B (8 bits)
--                     11 : MuxOut = Reste & Quotient de A / B
-- L'addition et la soustraction sont combinatoires (resultat immediat).
-- La multiplication et la division sont sequentielles : apres GReset, il faut
-- 10 fronts de GClock (BTNC) ; les fronts supplementaires sont sans effet
-- (les unites restent dans l'etat Done jusqu'au prochain GReset).
-- Signaux d'etat :
--   CarryOut    : retenue c4 de l'additionneur (operations 00 et 01)
--   OverflowOut : debordement de l'add/sub (00, 01) ou de la division (11),
--                 le produit 8 bits ne deborde jamais (10)
--   ZeroOut     : MuxOut = 00000000
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_top is
    port (
        GClock          : in  STD_LOGIC;
        GReset          : in  STD_LOGIC;
        CLK100MHZ       : in  STD_LOGIC;
        OperandA        : in  STD_LOGIC_VECTOR(3 downto 0);
        OperandB        : in  STD_LOGIC_VECTOR(3 downto 0);
        OperationSelect : in  STD_LOGIC_VECTOR(1 downto 0);
        MuxOut          : out STD_LOGIC_VECTOR(7 downto 0);
        CarryOut        : out STD_LOGIC;
        ZeroOut         : out STD_LOGIC;
        OverflowOut     : out STD_LOGIC;
        seg             : out STD_LOGIC_VECTOR(6 downto 0);
        an              : out STD_LOGIC_VECTOR(7 downto 0)
    );
end alu_top;

architecture structurel of alu_top is

    component addsubN
        generic ( N : positive );
        port (
            A, B   : in  STD_LOGIC_VECTOR(N-1 downto 0);
            AddSub : in  STD_LOGIC;
            S      : out STD_LOGIC_VECTOR(N-1 downto 0);
            CarryOut, OverflowOut, ZeroOut : out STD_LOGIC
        );
    end component;

    component multiplicateur
        port (
            GClock, GReset     : in  STD_LOGIC;
            OperandA, OperandB : in  STD_LOGIC_VECTOR(3 downto 0);
            Produit            : out STD_LOGIC_VECTOR(7 downto 0);
            Done               : out STD_LOGIC
        );
    end component;

    component diviseur
        port (
            GClock, GReset     : in  STD_LOGIC;
            OperandA, OperandB : in  STD_LOGIC_VECTOR(3 downto 0);
            Quotient, Reste    : out STD_LOGIC_VECTOR(3 downto 0);
            Ovf, Done          : out STD_LOGIC
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

    component display_controller
        port (
            CLK100MHZ : in  STD_LOGIC;
            valeur    : in  STD_LOGIC_VECTOR(7 downto 0);
            seg       : out STD_LOGIC_VECTOR(6 downto 0);
            an        : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal SommeDiff         : STD_LOGIC_VECTOR(3 downto 0);
    signal Produit           : STD_LOGIC_VECTOR(7 downto 0);
    signal Quotient, Reste   : STD_LOGIC_VECTOR(3 downto 0);
    signal AS_c, AS_v        : STD_LOGIC;
    signal Div_ovf, Div_done : STD_LOGIC;
    signal Res_AS, Res_Div   : STD_LOGIC_VECTOR(7 downto 0);
    signal Res               : STD_LOGIC_VECTOR(7 downto 0);
    signal ou                : STD_LOGIC_VECTOR(7 downto 0);   -- OU cumulatif de Res

begin

    -- Addition / soustraction : OperationSelect(0) = 0 -> A + B, 1 -> A - B
    AS : addsubN generic map (N => 4)
                 port map (A => OperandA, B => OperandB, AddSub => OperationSelect(0), S => SommeDiff,
                           CarryOut => AS_c, OverflowOut => AS_v, ZeroOut => open);

    -- Multiplication et division : tournent en parallele sur GClock / GReset
    MUL : multiplicateur port map (GClock => GClock, GReset => GReset, OperandA => OperandA,
                                   OperandB => OperandB, Produit => Produit, Done => open);
    DIV : diviseur port map (GClock => GClock, GReset => GReset, OperandA => OperandA,
                             OperandB => OperandB, Quotient => Quotient, Reste => Reste,
                             Ovf => Div_ovf, Done => Div_done);

    -- Multiplexeur de sortie (tableau 4)
    Res_AS  <= "0000" & SommeDiff;
    Res_Div <= Reste & Quotient;
    MUX_OUT : mux4N generic map (N => 8)
                    port map (sel => OperationSelect, D0 => Res_AS, D1 => Res_AS,
                              D2 => Produit, D3 => Res_Div, Y => Res);
    MuxOut <= Res;

    -- Signaux d'etat
    CarryOut    <= AS_c and (not OperationSelect(1));
    OverflowOut <= (AS_v and (not OperationSelect(1)))
                   or (OperationSelect(1) and OperationSelect(0) and Div_ovf and Div_done);

    -- ZeroOut : chaine de portes OU sur les 8 bits du resultat, puis inversion
    ou(0) <= Res(0);
    CHAINE_OU : for i in 1 to 7 generate
        ou(i) <= ou(i-1) or Res(i);
    end generate;
    ZeroOut <= not ou(7);

    -- Afficheur sept segments multiplexe
    AFF : display_controller port map (CLK100MHZ => CLK100MHZ, valeur => Res, seg => seg, an => an);

end structurel;
