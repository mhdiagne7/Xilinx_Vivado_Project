## Contraintes Nexys A7-100T du controleur de clavier (tableau 4 de l'enonce)
## Toutes les broches en LVCMOS33.

## Horloge globale 100 MHz
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { HorlogeG }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { HorlogeG }];

## Reset global (CPU_RESETN, actif a 0)
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { ResetG }];

## Clavier : le PIC24 de la carte recree les signaux PS/2 a partir du clavier USB (J5)
## Rappels a 1 : la ligne PS/2 est au repos a 1 (collecteur ouvert).
set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { HorlogeClavier }];
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 PULLUP true } [get_ports { InfoClavier }];

## Afficheur 7 segments : cathodes CA..CG, point decimal
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }];   # CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }];   # CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }];   # CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }];   # CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }];   # CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }];   # CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }];   # CG
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { DP }];

## Anodes AN0..AN7
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { AN[4] }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { AN[5] }];
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { AN[6] }];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { AN[7] }];

## Sorties BCD1 (LD15..LD12) et BCD2 (LD7..LD4)
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { BCD1[3] }];  # LD15
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { BCD1[2] }];  # LD14
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { BCD1[1] }];  # LD13
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { BCD1[0] }];  # LD12
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { BCD2[3] }];  # LD7
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { BCD2[2] }];  # LD6
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { BCD2[1] }];  # LD5
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { BCD2[0] }];  # LD4

## Proprietes du train de bits (Artix-7)
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

## Note : le filtre utilise une bascule SR synchrone (D = Set + Q.Reset'),
## il n'y a donc pas de boucle combinatoire et la derogation
## ALLOW_COMBINATORIAL_LOOPS de la section 8.3 n'est pas necessaire.
