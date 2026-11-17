-- Banc d'essai auto-verifiant des blocs d'entree du clavier :
-- filtre_digitale + detecteur_front + synchroniseur.
-- Verifie :
--  * un parasite de 50 ns (5 cycles) sur l'horloge du clavier est ignore ;
--  * un vrai front descendant donne UNE impulsion FD d'un seul cycle ;
--  * un parasite a 1 de 40 ns pendant le niveau bas ne donne pas de front ;
--  * un deuxieme front descendant donne une deuxieme impulsion ;
--  * le synchroniseur recopie InfoClavier avec 2 cycles de retard.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_entree_clavier is
end tb_entree_clavier;

architecture test of tb_entree_clavier is

    component filtre_digitale
        port (GClock, GResetBar, HorlogeClavier : in STD_LOGIC; HorlogeFiltree : out STD_LOGIC);
    end component;
    component detecteur_front
        port (GClock, GResetBar, Entree : in STD_LOGIC; FD : out STD_LOGIC);
    end component;
    component synchroniseur
        port (GClock, GResetBar, Entree : in STD_LOGIC; Sortie : out STD_LOGIC);
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock         : STD_LOGIC := '0';
    signal GResetBar      : STD_LOGIC := '0';
    signal HorlogeClavier : STD_LOGIC := '1';
    signal HorlogeFiltree : STD_LOGIC;
    signal FD             : STD_LOGIC;
    signal InfoClavier    : STD_LOGIC := '1';
    signal InfoSync       : STD_LOGIC;
    signal nb_fd          : integer := 0;
    signal erreurs        : integer := 0;
    signal err_fd         : integer := 0;   -- erreurs du processus COMPTE
    signal fin_sim        : boolean := false;

begin

    FILTRE : filtre_digitale port map (GClock => GClock, GResetBar => GResetBar,
                                       HorlogeClavier => HorlogeClavier, HorlogeFiltree => HorlogeFiltree);
    FRONT  : detecteur_front port map (GClock => GClock, GResetBar => GResetBar,
                                       Entree => HorlogeFiltree, FD => FD);
    SYNC   : synchroniseur port map (GClock => GClock, GResetBar => GResetBar,
                                     Entree => InfoClavier, Sortie => InfoSync);

    GClock <= not GClock after PERIODE / 2 when not fin_sim else '0';

    -- Compte les impulsions FD et verifie qu'elles ne durent qu'un cycle
    COMPTE : process (GClock)
        variable fd_prec : STD_LOGIC := '0';
    begin
        if rising_edge(GClock) then
            if FD = '1' then
                nb_fd <= nb_fd + 1;
                if fd_prec = '1' then
                    report "ERREUR : FD dure plus d'un cycle" severity error;
                    err_fd <= err_fd + 1;
                end if;
            end if;
            fd_prec := FD;
        end if;
    end process;

    STIMULI : process
        procedure verifie(cond : boolean; msg : string) is
        begin
            if not cond then
                report "ERREUR : " & msg severity error;
                erreurs <= erreurs + 1;
            end if;
        end procedure;
    begin
        wait for 25 ns;
        GResetBar <= '1';
        -- Ligne au repos : la sortie filtree monte a 1 apres 8 cycles
        wait for 200 ns;
        verifie(HorlogeFiltree = '1', "horloge filtree pas a 1 au repos");
        verifie(InfoSync = '1', "InfoSync pas a 1 au repos");

        -- 1) Parasite de 50 ns (5 cycles) : ignore
        HorlogeClavier <= '0'; wait for 50 ns; HorlogeClavier <= '1';
        wait for 200 ns;
        verifie(nb_fd = 0, "le parasite de 50 ns a donne un front");

        -- 2) Vrai front descendant (niveau bas de 500 ns) : une impulsion
        HorlogeClavier <= '0';
        wait for 200 ns;
        verifie(HorlogeFiltree = '0', "horloge filtree pas a 0 apres 200 ns");
        verifie(nb_fd = 1, "le vrai front n'a pas donne exactement une impulsion");
        -- 3) Parasite a 1 de 40 ns pendant le niveau bas : ignore
        HorlogeClavier <= '1'; wait for 40 ns; HorlogeClavier <= '0';
        wait for 260 ns;
        verifie(HorlogeFiltree = '0', "le parasite a 1 a change l'horloge filtree");
        verifie(nb_fd = 1, "le parasite a 1 a donne un front");
        HorlogeClavier <= '1';
        wait for 300 ns;
        verifie(HorlogeFiltree = '1', "horloge filtree pas revenue a 1");

        -- 4) Deuxieme front descendant : deuxieme impulsion
        HorlogeClavier <= '0';
        wait for 300 ns;
        verifie(nb_fd = 2, "le deuxieme front n'a pas donne d'impulsion");
        HorlogeClavier <= '1';

        -- 5) Synchroniseur : 2 cycles de retard
        wait until rising_edge(GClock);
        wait for 2 ns;
        InfoClavier <= '0';
        wait until rising_edge(GClock); wait for 1 ns;
        verifie(InfoSync = '1', "synchroniseur trop rapide");
        wait until rising_edge(GClock); wait for 1 ns;
        verifie(InfoSync = '0', "synchroniseur : retard different de 2 cycles");
        InfoClavier <= '1';
        wait for 100 ns;

        report "tb_entree_clavier termine : " & integer'image(erreurs + err_fd) & " erreur(s)";
        fin_sim <= true;
        wait;
    end process;

end test;
