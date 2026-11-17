#!/bin/sh
# Simulation en ligne de commande (XSim) d'un banc d'essai du Lab 4.
# Utilisation : sh scripts/sim_batch.sh tb_nom [duree]   (depuis Lab4_VivadoXilinx)
# Compile tous les fichiers de src/ et le banc d'essai, puis affiche les
# messages (report) du banc d'essai. Dossier de travail : build/sim_<tb>.
TB=$1; DUREE=${2:-all}
B=/c/Xilinx/Vivado/2022.1/bin
RACINE=$(cd "$(dirname "$0")/.." && pwd)
W=$RACINE/build/sim_$TB; mkdir -p "$W"; cd "$W" || exit 1
SRC=""
for f in "$RACINE"/src/*.vhd "$RACINE"/sim/$TB.vhd; do SRC="$SRC $(cygpath -w "$f")"; done
cmd //c "$(cygpath -w $B/xvhdl.bat) $SRC" > xvhdl.out 2>&1 || { grep -E "ERROR" xvhdl.out; exit 1; }
cmd //c "$(cygpath -w $B/xelab.bat) -debug typical $TB -s snap" > xelab.out 2>&1 || { grep -E "ERROR" xelab.out; exit 1; }
if [ "$DUREE" = "all" ]; then echo "run all" > run.tcl; else echo "run $DUREE" > run.tcl; fi
echo "quit" >> run.tcl
cmd //c "$(cygpath -w $B/xsim.bat) snap -tclbatch run.tcl" > xsim.out 2>&1
grep -E "Note:|Error:|ERREUR|Failure" xsim.out | head -40
