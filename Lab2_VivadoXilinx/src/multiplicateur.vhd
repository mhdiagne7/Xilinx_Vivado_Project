-- Multiplicateur signe 4 bits x 4 bits -> 8 bits (complement a 2).
-- Assemble le chemin de donnees et la logique de commande.
-- Apres GReset, Done passe a 1 au 10e front de GClock ; Produit est alors valide
-- et reste stable jusqu'au prochain GReset.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplicateur is
    port (
        GClock, GReset : in  STD_LOGIC;
        OperandA       : in  STD_LOGIC_VECTOR(3 downto 0);   -- multiplicande
        OperandB       : in  STD_LOGIC_VECTOR(3 downto 0);   -- multiplicateur
        Produit        : out STD_LOGIC_VECTOR(7 downto 0);
        Done           : out STD_LOGIC
    );
end multiplicateur;

architecture structurel of multiplicateur is

    component mult_datapath
        port (
            GClock, GReset : in  STD_LOGIC;
            OperandA, OperandB : in STD_LOGIC_VECTOR(3 downto 0);
            loadM, loadA, loadQ, loadC : in STD_LOGIC;
            selA           : in  STD_LOGIC_VECTOR(1 downto 0);
            selQ, selC     : in  STD_LOGIC;
            AddSub         : in  STD_LOGIC;
            Q0, Z0, Z1     : out STD_LOGIC;
            Produit        : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component mult_control
        port (
            GClock, GReset : in  STD_LOGIC;
            Q0, Z0, Z1     : in  STD_LOGIC;
            loadM, loadA, loadQ, loadC : out STD_LOGIC;
            selA           : out STD_LOGIC_VECTOR(1 downto 0);
            selQ, selC     : out STD_LOGIC;
            AddSub         : out STD_LOGIC;
            Done           : out STD_LOGIC
        );
    end component;

    -- Fils entre la commande et le chemin de donnees
    signal loadM, loadA, loadQ, loadC : STD_LOGIC;
    signal selA                       : STD_LOGIC_VECTOR(1 downto 0);
    signal selQ, selC, AddSub         : STD_LOGIC;
    signal Q0, Z0, Z1                 : STD_LOGIC;

begin

    DP : mult_datapath port map (
        GClock => GClock, GReset => GReset, OperandA => OperandA, OperandB => OperandB,
        loadM => loadM, loadA => loadA, loadQ => loadQ, loadC => loadC,
        selA => selA, selQ => selQ, selC => selC, AddSub => AddSub,
        Q0 => Q0, Z0 => Z0, Z1 => Z1, Produit => Produit
    );

    CTRL : mult_control port map (
        GClock => GClock, GReset => GReset, Q0 => Q0, Z0 => Z0, Z1 => Z1,
        loadM => loadM, loadA => loadA, loadQ => loadQ, loadC => loadC,
        selA => selA, selQ => selQ, selC => selC, AddSub => AddSub, Done => Done
    );

end structurel;
