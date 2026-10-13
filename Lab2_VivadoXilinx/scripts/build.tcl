# Compile l'ALU du Lab 2 jusqu'au bitstream, sans projet Vivado (mode non-projet).
# Utilisation (depuis n'importe quel dossier) :
#   vivado -mode batch -source <chemin>/Lab2_VivadoXilinx/scripts/build.tcl
# Resultats : Lab2_VivadoXilinx/build/ (rapports) et bitstream/lab2_alu.bit
set racine [file normalize [file join [file dirname [info script]] ..]]
set sortie [file join $racine build]
file mkdir $sortie

# Sources du design (les bancs d'essai de sim/ ne sont pas synthetises)
foreach f [glob -directory [file join $racine src] *.vhd] { read_vhdl $f }
read_xdc [file join $racine constraints nexys_a7_100t.xdc]

synth_design -top alu_top -part xc7a100tcsg324-1
report_utilization -file [file join $sortie utilisation_synth.rpt]
opt_design
place_design
route_design
report_timing_summary -file [file join $sortie timing.rpt]
report_drc -file [file join $sortie drc.rpt]

set bit [file normalize [file join $racine .. bitstream lab2_alu.bit]]
file mkdir [file dirname $bit]
write_bitstream -force $bit
puts "Bitstream : $bit"
