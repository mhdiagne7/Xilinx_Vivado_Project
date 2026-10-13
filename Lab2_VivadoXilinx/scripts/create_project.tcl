# Cree le projet Vivado du Lab 2 (lab2.xpr) dans Lab2_VivadoXilinx/.
# Les sources sont referencees sans copie, avec des chemins relatifs au
# projet : le .xpr fonctionne sur n'importe quel PC apres un git clone.
# Utilisation (une seule fois, le .xpr est ensuite versionne) :
#   vivado -mode batch -source <chemin>/Lab2_VivadoXilinx/scripts/create_project.tcl
set racine [file normalize [file join [file dirname [info script]] ..]]
if {[file exists [file join $racine lab2.xpr]]} {
    error "lab2.xpr existe deja : ouvrez-le avec File > Open Project."
}
create_project lab2 $racine -part xc7a100tcsg324-1
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

# Design : tous les .vhd de src/, top = alu_top
add_files -norecurse [glob -directory [file join $racine src] *.vhd]
set_property top alu_top [get_filesets sources_1]

# Contraintes de la Nexys A7-100T
add_files -fileset constrs_1 -norecurse [file join $racine constraints nexys_a7_100t.xdc]

# Une configuration de simulation par banc d'essai, avec sa vue et sa duree.
# sim_1 (active par defaut) = ALU complete ; les autres se choisissent par
# clic droit > Make Active dans Simulation Sources.
set simsets {
    sim_1     tb_alu_top        280ns
    sim_addsub tb_addsub4       90ns
    sim_mult  tb_multiplicateur 120ns
    sim_div   tb_diviseur       240ns
}
foreach {fs tb duree} $simsets {
    if {[llength [get_filesets -quiet $fs]] == 0} { create_fileset -simset $fs }
    set vue [file join $racine sim ${tb}_behav.wcfg]
    add_files -fileset $fs -norecurse [list [file join $racine sim $tb.vhd] $vue]
    set_property top $tb [get_filesets $fs]
    set_property top_lib xil_defaultlib [get_filesets $fs]
    set_property -name {xsim.simulate.runtime} -value $duree -objects [get_filesets $fs]
    set_property -name {xsim.view} -value [list $vue] -objects [get_filesets $fs]
}
current_fileset -simset [get_filesets sim_1]
update_compile_order -fileset sources_1
puts "Projet cree : [file join $racine lab2.xpr]"
close_project
