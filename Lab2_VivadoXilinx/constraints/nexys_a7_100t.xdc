## Contraintes Nexys A7-100T pour l'ALU du Lab 2 (tableau 5 de l'enonce)

## Horloge 100 MHz (rafraichissement de l'afficheur seulement)
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK100MHZ }];

## Boutons : GClock (pas-a-pas) et GReset
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { GClock }];   # BTNC
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { GReset }];   # BTNU
## GClock vient d'un bouton qui n'est pas sur une broche d'horloge
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -quiet GClock_IBUF];
create_clock -add -name gclock_btn -period 100.00 [get_ports { GClock }];
set_clock_groups -asynchronous -group [get_clocks sys_clk_pin] -group [get_clocks gclock_btn];

## OperandA = SW7..SW4
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { OperandA[3] }];   # SW7
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { OperandA[2] }];   # SW6
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { OperandA[1] }];   # SW5
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { OperandA[0] }];   # SW4

## OperandB = SW3..SW0
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { OperandB[3] }];   # SW3
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { OperandB[2] }];   # SW2
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { OperandB[1] }];   # SW1
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { OperandB[0] }];   # SW0

## OperationSelect = SW9..SW8 (banc 1,8 V)
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS18 } [get_ports { OperationSelect[1] }];   # SW9
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS18 } [get_ports { OperationSelect[0] }];   # SW8

## MuxOut = LED15..LED8
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[7] }];   # LED15
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[6] }];   # LED14
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[5] }];   # LED13
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[4] }];   # LED12
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[3] }];   # LED11
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[2] }];   # LED10
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[1] }];   # LED9
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { MuxOut[0] }];   # LED8

## LED d'etat
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { CarryOut }];      # LED0
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { ZeroOut }];       # LED1
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { OverflowOut }];   # LED2

## Afficheur sept segments : cathodes CA..CG (actives a l'etat bas)
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { seg[6] }];   # CA
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { seg[5] }];   # CB
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { seg[4] }];   # CC
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { seg[3] }];   # CD
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { seg[2] }];   # CE
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { seg[1] }];   # CF
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { seg[0] }];   # CG

## Afficheur sept segments : anodes AN0..AN7 (actives a l'etat bas)
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { an[0] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { an[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { an[2] }];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { an[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { an[4] }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { an[5] }];
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { an[6] }];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { an[7] }];

## Configuration (supprime l'avertissement DRC CFGBVS-1)
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];
