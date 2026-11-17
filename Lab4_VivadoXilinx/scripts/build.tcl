# Compile le controleur de clavier du Lab 4 jusqu'au bitstream (mode non-projet).
# Utilisation : vivado -mode batch -source <chemin>/Lab4_VivadoXilinx/scripts/build.tcl
# Resultats : Lab4_VivadoXilinx/build/ (rapports) et bitstream/lab4_clavier.bit
set racine [file normalize [file join [file dirname [info script]] ..]]
set sortie [file join $racine build]
file mkdir $sortie

foreach f [glob -directory [file join $racine src] *.vhd] { read_vhdl $f }
read_xdc [file join $racine constraints controleurClavier.xdc]

synth_design -top controleurClavier -part xc7a100tcsg324-1
report_utilization -file [file join $sortie utilisation_synth.rpt]
opt_design
place_design
route_design
report_utilization -file [file join $sortie utilisation_impl.rpt]
report_timing_summary -file [file join $sortie timing.rpt]
report_drc -file [file join $sortie drc.rpt]

set bit [file normalize [file join $racine .. bitstream lab4_clavier.bit]]
write_bitstream -force $bit
puts "Bitstream : $bit"
