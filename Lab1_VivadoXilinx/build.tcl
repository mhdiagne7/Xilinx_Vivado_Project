# Reconstruit le bitstream depuis zero (runs remis a zero).
# Utilisation : vivado -mode batch -source build.tcl   (depuis ce dossier)
open_project [file join [file dirname [info script]] Lab1_VivadoXilinx.xpr]

# S'assurer que toutes les sources sont dans le projet (compare par nom de
# fichier : get_files decoupe les chemins qui contiennent des espaces).
set src [get_property DIRECTORY [current_project]]/Lab1_VivadoXilinx.srcs
set deja {}
foreach f [get_files -quiet *.vhd] { lappend deja [file tail $f] }
foreach {fs dir} {sources_1 sources_1/new sim_1 sim_1/new} {
    foreach f [glob -nocomplain -directory $src/$dir *.vhd] {
        if {[lsearch -exact $deja [file tail $f]] < 0} { add_files -fileset $fs [list $f] }
    }
}
set_property top main [get_filesets sources_1]
set_property top tb_main [get_filesets sim_1]
update_compile_order -fileset sources_1

# Pas de synthese incrementale : l'ancien checkpoint (utils_1/.../main.dcp)
# vient d'un autre design, et Vivado ne met pas son chemin entre guillemets,
# ce qui fait echouer la synthese si le dossier contient un espace.
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
set_property INCREMENTAL_CHECKPOINT {} [get_runs synth_1]
set dcp [get_files -quiet -of_objects [get_filesets utils_1] *.dcp]
if {[llength $dcp]} { remove_files -fileset utils_1 $dcp }

reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
puts "synth_1 : [get_property STATUS [get_runs synth_1]]"
puts "impl_1  : [get_property STATUS [get_runs impl_1]]"
close_project
