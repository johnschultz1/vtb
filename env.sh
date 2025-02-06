#!/bin/bash
export WD="$(pwd -P)"

# location to VTB
export VTBHOME=$WD
# location to Verilator home dir, uncomment and set
#export VERIHOME=''
# location to Verilator exe
export VERIEXE='$VERIHOME/bin/verilator'
# options to pass to verilator
export VERIOPTS=' --debug --Wno-lint --sv --timing --trace --public --trace-structs '
# includes to pass to verilator
export VERIINC=' -I$VERIHOME/include -I$VTBHOME/src -I$PROJECTSHOME/$PROJECTNAME/verif/run/vtb '
# location to Slang exe
export SLANGEXE='slang'
# options to pass to slang
export SLANGOPTS='--allow-toplevel-iface-ports'
export PROJECTSHOME=/home/$(whoami)/VTB_PROJECTS/
export PROJECTNAME=newPrj
# gtk wave viewing exports
export GTK_MODULES=gail:atk-bridge
export GTK_PATH=/usr/lib/x86_64-linux-gnu/gtk-2.0/modules
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
