# Cree le projet Vivado du Lab 3 (lab3.xpr) dans Lab3_VivadoXilinx/.
# Sources referencees sans copie, chemins relatifs au projet : le .xpr
# fonctionne sur n'importe quel PC apres un git clone.
# Utilisation (une seule fois, le .xpr est ensuite versionne) :
#   vivado -mode batch -source <chemin>/Lab3_VivadoXilinx/scripts/create_project.tcl
set racine [file normalize [file join [file dirname [info script]] ..]]
if {[file exists [file join $racine lab3.xpr]]} {
    error "lab3.xpr existe deja : ouvrez-le avec File > Open Project."
}
create_project lab3 $racine -part xc7a100tcsg324-1
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

# Design : tous les .vhd de src/, top = controleur_feux
add_files -norecurse [glob -directory [file join $racine src] *.vhd]
set_property top controleur_feux [get_filesets sources_1]

# Contraintes de la Nexys A7-100T
add_files -fileset constrs_1 -norecurse [file join $racine constraints nexys_a7_100t_lab3.xdc]

# Une configuration de simulation par banc d'essai, avec sa vue et sa duree.
# sim_1 (active par defaut) = systeme complet ; les autres se choisissent par
# clic droit > Make Active dans Simulation Sources.
set simsets {
    sim_1         tb_systeme_feux     44us
    sim_fsm       tb_fsm_controleur   5us
    sim_compteur  tb_compteur_vert    4us
    sim_minuterie tb_minuterie_jaunes 200ns
    sim_entree    tb_entree_voiture   400ns
    sim_affichage tb_affichage        100ns
    sim_clkdiv    tb_clk_div          25ms
}
foreach {fs tb duree} $simsets {
    if {[llength [get_filesets -quiet $fs]] == 0} { create_fileset -simset $fs }
    set vue [file join $racine sim ${tb}_behav.wcfg]
    add_files -fileset $fs -norecurse [list [file join $racine sim $tb.vhd] $vue]
    set_property top $tb [get_filesets $fs]
    set_property top_lib xil_defaultlib [get_filesets $fs]
    set_property -name {xsim.simulate.runtime} -value $duree -objects [get_filesets $fs]
}
current_fileset -simset [get_filesets sim_1]
update_compile_order -fileset sources_1
puts "Projet cree : [file join $racine lab3.xpr]"
close_project
