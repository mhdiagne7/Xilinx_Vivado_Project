-- Banc d'essai auto-verifiant du controleur FSM.
-- Partie 1 : scenario lisible (un cycle complet des feux).
-- Partie 2 : depuis chacun des 4 etats, les 32 combinaisons des 5 entrees,
--            comparees a la table de transition (etape 6).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fsm_controleur is
end tb_fsm_controleur;

architecture test of tb_fsm_controleur is

    component fsm_controleur
        port (
            GClock, GResetBar, Load       : in  STD_LOGIC;
            SSCS, MSCE, MTE, SSCE, STE    : in  STD_LOGIC;
            MSTL, SSTL                    : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal Load      : STD_LOGIC := '1';
    signal SSCS, MSCE, MTE, SSCE, STE : STD_LOGIC := '0';
    signal MSTL, SSTL : STD_LOGIC_VECTOR(2 downto 0);

    -- Feux attendus pour chaque etat (rouge, jaune, vert)
    constant VERT  : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant JAUNE : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant ROUGE : STD_LOGIC_VECTOR(2 downto 0) := "100";

begin

    UUT : fsm_controleur port map (
        GClock => GClock, GResetBar => GResetBar, Load => Load,
        SSCS => SSCS, MSCE => MSCE, MTE => MTE, SSCE => SSCE, STE => STE,
        MSTL => MSTL, SSTL => SSTL
    );

    stimulus : process
        variable erreurs : integer := 0;
        variable e       : STD_LOGIC_VECTOR(4 downto 0);   -- SSCS MSCE MTE SSCE STE

        -- Un front montant d'horloge : les entrees ont une demi-periode pour se
        -- stabiliser avant le front, puis on attend que les sorties suivent
        procedure front is
        begin
            wait for PERIODE / 2;
            GClock <= '1'; wait for PERIODE / 2;
            GClock <= '0';
        end procedure;

        -- Verifie les feux ; etat est 'A', 'B', 'C' ou 'D'
        procedure verifier (etat : character; msg : string) is
            variable ms, ss : STD_LOGIC_VECTOR(2 downto 0);
        begin
            case etat is
                when 'A'    => ms := VERT;  ss := ROUGE;
                when 'B'    => ms := JAUNE; ss := ROUGE;
                when 'C'    => ms := ROUGE; ss := VERT;
                when others => ms := ROUGE; ss := JAUNE;
            end case;
            if MSTL /= ms or SSTL /= ss then
                erreurs := erreurs + 1;
                report "ERREUR (" & msg & ") : etat " & etat & " attendu" severity error;
            end if;
        end procedure;

        -- Amene la machine dans un etat donne en suivant le cycle
        procedure aller_a (etat : character) is
        begin
            SSCS <= '0'; MSCE <= '0'; MTE <= '0'; SSCE <= '0'; STE <= '0';
            GResetBar <= '0'; wait for PERIODE; GResetBar <= '1';
            if etat /= 'A' then
                SSCS <= '1'; MSCE <= '1'; front; SSCS <= '0'; MSCE <= '0';
                if etat /= 'B' then
                    MTE <= '1'; front; MTE <= '0';
                    if etat /= 'C' then
                        SSCE <= '1'; front; SSCE <= '0';
                    end if;
                end if;
            end if;
        end procedure;

        -- Etat suivant attendu d'apres la table de transition
        function suivant (etat : character; v : STD_LOGIC_VECTOR(4 downto 0)) return character is
        begin
            case etat is
                when 'A' => if v(4) = '1' and v(3) = '1' then return 'B'; else return 'A'; end if;
                when 'B' => if v(2) = '1' then return 'C'; else return 'B'; end if;
                when 'C' => if v(1) = '1' then return 'D'; else return 'C'; end if;
                when others => if v(0) = '1' then return 'A'; else return 'D'; end if;
            end case;
        end function;

        type etats_t is array (0 to 3) of character;
        constant ETATS : etats_t := ('A', 'B', 'C', 'D');

    begin
        -- Partie 1 : un cycle complet
        wait for PERIODE; GResetBar <= '1';
        verifier('A', "apres reset");
        MSCE <= '1'; front; verifier('A', "MSC atteint sans voiture : on reste");
        SSCS <= '1'; front; verifier('B', "MSC atteint et voiture : MS jaune");
        SSCS <= '0'; MSCE <= '0';
        front; verifier('B', "jaune MS pas fini : on reste");
        MTE <= '1'; front; verifier('C', "jaune MS fini : SS vert"); MTE <= '0';
        front; verifier('C', "SSC pas atteint : on reste");
        SSCE <= '1'; front; verifier('D', "SSC atteint : SS jaune"); SSCE <= '0';
        STE <= '1'; front; verifier('A', "jaune SS fini : retour MS vert"); STE <= '0';
        Load <= '0'; SSCS <= '1'; MSCE <= '1'; front; front;
        verifier('A', "Load = 0 : machine figee");
        Load <= '1'; front; verifier('B', "Load = 1 : la machine repart");
        SSCS <= '0'; MSCE <= '0';
        wait for 2 * PERIODE;

        -- Partie 2 : 4 etats x 32 combinaisons d'entrees
        for i in ETATS'range loop
            for n in 0 to 31 loop
                aller_a(ETATS(i));
                e := std_logic_vector(to_unsigned(n, 5));
                SSCS <= e(4); MSCE <= e(3); MTE <= e(2); SSCE <= e(1); STE <= e(0);
                front;
                verifier(suivant(ETATS(i), e), "table de transition");
            end loop;
        end loop;

        report "Fin de la simulation : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
