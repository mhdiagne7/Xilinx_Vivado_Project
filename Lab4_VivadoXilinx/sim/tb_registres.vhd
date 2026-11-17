-- Banc d'essai auto-verifiant du registre a decalage et du registre d'affichage.
-- 1) On decale les 10 bits de la trame de « a » (1C) : d0..d7 = 0,0,1,1,1,0,0,0,
--    parite = 0, arret = 1 -> Octet doit valoir 1C.
-- 2) Charge = 1 copie 1C dans le registre d'affichage.
-- 3) On decale la trame F0 avec Charge = 0 : l'affichage garde 1C pendant
--    que le registre a decalage change ; Charge = 1 copie ensuite F0.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_registres is
end tb_registres;

architecture test of tb_registres is

    component registre_decalage
        port (
            GClock, GResetBar, Decale, Info : in STD_LOGIC;
            Trame : out STD_LOGIC_VECTOR(9 downto 0);
            Octet : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    component registre8
        port (
            GClock, GResetBar, Charge : in STD_LOGIC;
            D : in STD_LOGIC_VECTOR(7 downto 0);
            Q : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    constant PERIODE : time := 10 ns;

    signal GClock    : STD_LOGIC := '0';
    signal GResetBar : STD_LOGIC := '0';
    signal Decale    : STD_LOGIC := '0';
    signal Info      : STD_LOGIC := '1';
    signal Charge    : STD_LOGIC := '0';
    signal Trame     : STD_LOGIC_VECTOR(9 downto 0);
    signal Octet     : STD_LOGIC_VECTOR(7 downto 0);
    signal Affiche   : STD_LOGIC_VECTOR(7 downto 0);
    signal erreurs   : integer := 0;

begin

    DECAL : registre_decalage port map (GClock => GClock, GResetBar => GResetBar,
                                        Decale => Decale, Info => Info, Trame => Trame, Octet => Octet);
    AFF   : registre8 port map (GClock => GClock, GResetBar => GResetBar, Charge => Charge,
                                D => Octet, Q => Affiche);

    process
        procedure front is
        begin
            wait for PERIODE / 2;
            GClock <= '1';
            wait for PERIODE / 2;
            GClock <= '0';
        end procedure;

        -- Envoie les 10 bits d'une trame (LSB en premier), un Decale par bit
        procedure trame_de(octet_v : STD_LOGIC_VECTOR(7 downto 0)) is
            variable p : STD_LOGIC := '1';
        begin
            for i in 0 to 7 loop
                p := p xor octet_v(i);              -- parite impaire
            end loop;
            for i in 0 to 9 loop
                if i < 8 then Info <= octet_v(i);
                elsif i = 8 then Info <= p;
                else Info <= '1'; end if;
                Decale <= '1'; front;
                Decale <= '0'; front; front;        -- attente entre deux bits
            end loop;
            Info <= '1';
        end procedure;

        procedure verifie(cond : boolean; msg : string) is
        begin
            wait for 1 ns;
            if not cond then
                report "ERREUR : " & msg severity error;
                erreurs <= erreurs + 1;
            end if;
        end procedure;
    begin
        wait for 3 ns;
        GResetBar <= '1';
        verifie(Affiche = x"00", "affichage pas a 00 apres le reset");

        trame_de(x"1C");
        verifie(Octet = x"1C", "octet different de 1C");
        verifie(Trame(9 downto 8) = "10", "arret/parite de 1C incorrects");
        verifie(Affiche = x"00", "l'affichage a change sans Charge");
        Charge <= '1'; front; Charge <= '0';
        verifie(Affiche = x"1C", "Charge n'a pas copie 1C");

        trame_de(x"F0");
        verifie(Octet = x"F0", "octet different de F0");
        verifie(Trame(9 downto 8) = "11", "arret/parite de F0 incorrects");
        verifie(Affiche = x"1C", "l'affichage n'a pas garde 1C");
        Charge <= '1'; front; Charge <= '0';
        verifie(Affiche = x"F0", "Charge n'a pas copie F0");

        report "tb_registres termine : " & integer'image(erreurs) & " erreur(s)";
        wait;
    end process;

end test;
