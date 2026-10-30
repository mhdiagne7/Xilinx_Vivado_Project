## Contraintes Nexys A7-100T pour le controleur de feux (tableau 10 de l'enonce)

## Horloge 100 MHz
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { CLOCK }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLOCK }];

## Reset (CPU_RESETN, actif a 0) et activation de la FSM
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { RESETBAR }];
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { LOAD_FSM }];   # SW0

## Capteur de voiture (BTNU)
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { CAPTEUR }];

## MSC_MAX = SW4..SW1
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { MSC_MAX[0] }];   # SW1
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { MSC_MAX[1] }];   # SW2
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { MSC_MAX[2] }];   # SW3
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { MSC_MAX[3] }];   # SW4

## SSC_MAX = SW8..SW5 (SW8 est sur un banc a 1,8 V : LVCMOS18, mise en garde (i))
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { SSC_MAX[0] }];   # SW5
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { SSC_MAX[1] }];   # SW6
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { SSC_MAX[2] }];   # SW7
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS18 } [get_ports { SSC_MAX[3] }];   # SW8

## Feu de la rue principale : LED RGB LD16
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports { MSTL[0] }];   # vert
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 } [get_ports { MSTL[1] }];   # bleu
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports { MSTL[2] }];   # rouge

## Feu de la rue secondaire : LED RGB LD17
set_property -dict { PACKAGE_PIN R11 IOSTANDARD LVCMOS33 } [get_ports { SSTL[0] }];   # vert
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports { SSTL[1] }];   # bleu
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports { SSTL[2] }];   # rouge

## Afficheur sept segments : cathodes CA..CG (actives a 0)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }];   # CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }];   # CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }];   # CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }];   # CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }];   # CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }];   # CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }];   # CG

## Afficheur sept segments : anodes AN0..AN7 (actives a 0)
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { AN[4] }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { AN[5] }];
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { AN[6] }];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { AN[7] }];

## Configuration (supprime l'avertissement DRC CFGBVS-1)
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];
