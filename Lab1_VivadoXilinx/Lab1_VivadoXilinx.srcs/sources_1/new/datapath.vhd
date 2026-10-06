library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        en         : in  STD_LOGIC;
        loadDis    : in  STD_LOGIC;
        selDis     : in  STD_LOGIC_VECTOR(1 downto 0);
        loadL      : in  STD_LOGIC;
        selL       : in  STD_LOGIC;
        loadR      : in  STD_LOGIC;
        selR       : in  STD_LOGIC;
        DISPLAY_out: out STD_LOGIC_VECTOR(7 downto 0)
    );
end datapath;

architecture structurel of datapath is

    component registre8
        port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            en     : in  STD_LOGIC;
            load   : in  STD_LOGIC;
            D      : in  STD_LOGIC_VECTOR(7 downto 0);
            Q      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component mux2to1_8bits
        port (
            sel    : in  STD_LOGIC;
            entree0: in  STD_LOGIC_VECTOR(7 downto 0);
            entree1: in  STD_LOGIC_VECTOR(7 downto 0);
            sortie : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component mux4to1_8bits
        port (
            sel     : in  STD_LOGIC_VECTOR(1 downto 0);
            entree0 : in  STD_LOGIC_VECTOR(7 downto 0);
            entree1 : in  STD_LOGIC_VECTOR(7 downto 0);
            entree2 : in  STD_LOGIC_VECTOR(7 downto 0);
            entree3 : in  STD_LOGIC_VECTOR(7 downto 0);
            sortie  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component or8bits
        port (
            entreeA : in  STD_LOGIC_VECTOR(7 downto 0);
            entreeB : in  STD_LOGIC_VECTOR(7 downto 0);
            sortie  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal LMASK_val, RMASK_val : STD_LOGIC_VECTOR(7 downto 0);
    signal decale_L, decale_R   : STD_LOGIC_VECTOR(7 downto 0);
    signal or_result            : STD_LOGIC_VECTOR(7 downto 0);
    signal mux_L_out, mux_R_out : STD_LOGIC_VECTOR(7 downto 0);
    signal mux_Dis_out          : STD_LOGIC_VECTOR(7 downto 0);

    constant INIT_L   : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
    constant INIT_R   : STD_LOGIC_VECTOR(7 downto 0) := "10000000";
    constant INIT_DIS : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

begin

    -- Decalages en rotation : le bit qui sort d'un cote rentre de l'autre,
    -- sinon le masque devient 00000000 apres 8 pas et la lumiere disparait.
    decale_L <= LMASK_val(6 downto 0) & LMASK_val(7);   -- LMASK << 1
    decale_R <= RMASK_val(0) & RMASK_val(7 downto 1);   -- RMASK >> 1

    U_OR : or8bits port map (
        entreeA => LMASK_val,
        entreeB => RMASK_val,
        sortie  => or_result
    );

    U_MUX_L : mux2to1_8bits port map (
        sel     => selL,
        entree0 => INIT_L,
        entree1 => decale_L,
        sortie  => mux_L_out
    );

    U_REG_L : registre8 port map (
        clk   => clk,
        reset => reset,
        en    => en,
        load  => loadL,
        D     => mux_L_out,
        Q     => LMASK_val
    );

    U_MUX_R : mux2to1_8bits port map (
        sel     => selR,
        entree0 => INIT_R,
        entree1 => decale_R,
        sortie  => mux_R_out
    );

    U_REG_R : registre8 port map (
        clk   => clk,
        reset => reset,
        en    => en,
        load  => loadR,
        D     => mux_R_out,
        Q     => RMASK_val
    );

    U_MUX_DIS : mux4to1_8bits port map (
        sel     => selDis,
        entree0 => INIT_DIS,
        entree1 => LMASK_val,
        entree2 => RMASK_val,
        entree3 => or_result,
        sortie  => mux_Dis_out
    );

    U_REG_DIS : registre8 port map (
        clk   => clk,
        reset => reset,
        en    => en,
        load  => loadDis,
        D     => mux_Dis_out,
        Q     => DISPLAY_out
    );

end structurel;