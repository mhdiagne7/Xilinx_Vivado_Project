-- Banc d'essai auto-verifiant du controleur d'affichage, cas unique :
-- LEFT et RIGHT : les deux mouvements combines.
-- N_DIV est reduit a 4 pour que l'impulsion de validation arrive vite.
-- Un modele de reference du pseudocode (avec la latence d'un pas de la
-- machine a etats) calcule l'affichage attendu a chaque pas.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_main_deux is
end tb_main_deux;

architecture sim of tb_main_deux is

    constant N_DIV : positive := 4;
    constant CLK_T : time     := 10 ns;
    constant PAS   : time     := N_DIV * CLK_T;   -- duree d'un pas d'animation

    signal CLK100MHZ : STD_LOGIC := '0';
    signal SW_RESET  : STD_LOGIC := '1';
    signal SW_LEFT   : STD_LOGIC := '0';
    signal SW_RIGHT  : STD_LOGIC := '0';
    signal LED_OUT   : STD_LOGIC_VECTOR(7 downto 0);
    signal fin       : boolean := false;

    type pas_t is record
        left, right : STD_LOGIC;
        nb          : natural;       -- nombre de pas avec ces interrupteurs
    end record;
    type plan_t is array (natural range <>) of pas_t;
    constant PLAN : plan_t := (0 => ('1', '1', 12));   -- LEFT et RIGHT : les deux mouvements combines

begin

    CLK100MHZ <= not CLK100MHZ after CLK_T / 2 when not fin else '0';

    DUT : entity work.main
        generic map ( N_DIV => N_DIV )
        port map (
            CLK100MHZ => CLK100MHZ,
            SW_RESET  => SW_RESET,
            SW_LEFT   => SW_LEFT,
            SW_RIGHT  => SW_RIGHT,
            LED_OUT   => LED_OUT
        );

    stimulus : process
        type etat_t is (S0, S1, S2, S3, S4);
        variable etat  : etat_t := S0;
        variable disp  : STD_LOGIC_VECTOR(7 downto 0) := x"00";
        variable lmask : STD_LOGIC_VECTOR(7 downto 0) := x"01";
        variable rmask : STD_LOGIC_VECTOR(7 downto 0) := x"80";
        variable erreurs, total : natural := 0;
    begin
        -- Reset relache entre deux fronts (fronts montants a 5, 15, 25 ns...).
        -- Premier pas execute au front N_DIV+1 apres le relachement.
        wait for 22 ns;
        SW_RESET <= '0';
        wait for 3 ns + PAS / 2;          -- milieu de periode avant le 1er pas

        for i in PLAN'range loop
            for k in 1 to PLAN(i).nb loop
                SW_LEFT  <= PLAN(i).left;
                SW_RIGHT <= PLAN(i).right;
                wait for PAS;             -- un front avec en = '1' passe

                -- Modele de reference : executer l'etat courant ...
                case etat is
                    when S0 => disp := x"00"; lmask := x"01"; rmask := x"80";
                    when S1 => disp := lmask or rmask;
                               lmask := lmask(6 downto 0) & lmask(7);
                               rmask := rmask(0) & rmask(7 downto 1);
                    when S2 => disp := lmask;
                               lmask := lmask(6 downto 0) & lmask(7);
                    when S3 => disp := rmask;
                               rmask := rmask(0) & rmask(7 downto 1);
                    when S4 => disp := x"00";
                end case;
                -- ... puis choisir l'etat suivant selon les interrupteurs.
                if    PLAN(i).left = '1' and PLAN(i).right = '1' then etat := S1;
                elsif PLAN(i).left = '1'                         then etat := S2;
                elsif PLAN(i).right = '1'                        then etat := S3;
                else                                                  etat := S4;
                end if;

                total := total + 1;
                if LED_OUT /= disp then
                    erreurs := erreurs + 1;
                    report "Pas " & integer'image(total) & " : LED_OUT incorrect"
                        severity error;
                end if;
            end loop;
        end loop;

        -- GReset en cours de route : tout revient a zero immediatement.
        SW_RESET <= '1';
        wait for CLK_T;
        total := total + 1;
        if LED_OUT /= x"00" then
            erreurs := erreurs + 1;
            report "Reset : LED_OUT n'est pas a 0" severity error;
        end if;

        report "FIN DE SIMULATION : " & integer'image(total) & " verifications, "
            & integer'image(erreurs) & " erreur(s)" severity note;
        fin <= true;
        wait;
    end process;

end sim;
