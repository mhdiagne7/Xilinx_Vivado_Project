-- Diviseur signe 4 bits : Quotient = OperandA / OperandB (tronque vers zero),
-- Reste du meme signe que OperandA, OperandA = Quotient x OperandB + Reste.
-- Assemble le chemin de donnees et la logique de commande.
-- Apres GReset, Done passe a 1 au 10e front de GClock.
-- Ovf = 1 pour la division par zero et pour -8 / -1.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity diviseur is
    port (
        GClock, GReset : in  STD_LOGIC;
        OperandA       : in  STD_LOGIC_VECTOR(3 downto 0);   -- dividende
        OperandB       : in  STD_LOGIC_VECTOR(3 downto 0);   -- diviseur
        Quotient       : out STD_LOGIC_VECTOR(3 downto 0);
        Reste          : out STD_LOGIC_VECTOR(3 downto 0);
        Ovf            : out STD_LOGIC;
        Done           : out STD_LOGIC
    );
end diviseur;

architecture structurel of diviseur is

    component div_datapath
        port (
            GClock, GReset     : in  STD_LOGIC;
            OperandA, OperandB : in  STD_LOGIC_VECTOR(3 downto 0);
            loadR, selR, loadD, selD, loadQ, selQ, loadC, selC, loadS : in STD_LOGIC;
            Acc, Z0            : out STD_LOGIC;
            Quotient, Reste    : out STD_LOGIC_VECTOR(3 downto 0);
            Ovf                : out STD_LOGIC
        );
    end component;

    component div_control
        port (
            GClock, GReset : in  STD_LOGIC;
            Acc, Z0        : in  STD_LOGIC;
            loadR, selR, loadD, selD, loadQ, selQ, loadC, selC, loadS : out STD_LOGIC;
            Done           : out STD_LOGIC
        );
    end component;

    -- Fils entre la commande et le chemin de donnees
    signal loadR, selR, loadD, selD, loadQ, selQ, loadC, selC, loadS : STD_LOGIC;
    signal Acc, Z0 : STD_LOGIC;

begin

    DP : div_datapath port map (
        GClock => GClock, GReset => GReset, OperandA => OperandA, OperandB => OperandB,
        loadR => loadR, selR => selR, loadD => loadD, selD => selD, loadQ => loadQ,
        selQ => selQ, loadC => loadC, selC => selC, loadS => loadS,
        Acc => Acc, Z0 => Z0, Quotient => Quotient, Reste => Reste, Ovf => Ovf
    );

    CTRL : div_control port map (
        GClock => GClock, GReset => GReset, Acc => Acc, Z0 => Z0,
        loadR => loadR, selR => selR, loadD => loadD, selD => selD, loadQ => loadQ,
        selQ => selQ, loadC => loadC, selC => selC, loadS => loadS, Done => Done
    );

end structurel;
