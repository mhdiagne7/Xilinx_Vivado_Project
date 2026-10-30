# Compile le controleur de feux du Lab 3 jusqu'au bitstream (mode non-projet).
# Utilisation : vivado -mode batch -source <chemin>/Lab3_VivadoXilinx/scripts/build.tcl
# Resultats : Lab3_VivadoXilinx/build/ (rapports) et bitstream/lab3_feux.bit
set racine [file normalize [file join [file dirname [info script]] ..]]
set sortie [file join $racine build]
file mkdir $sortie

foreach f [glob -directory [file join $racine src] *.vhd] { read_vhdl $f }
read_xdc [file join $racine constraints nexys_a7_100t_lab3.xdc]

synth_design -top controleur_feux -part xc7a100tcsg324-1
report_utilization -file [file join $sortie utilisation_synth.rpt]
opt_design
place_design
route_design
report_timing_summary -file [file join $sortie timing.rpt]
report_drc -file [file join $sortie drc.rpt]

set bit [file normalize [file join $racine .. bitstream lab3_feux.bit]]
write_bitstream -force $bit
puts "Bitstream : $bit"
