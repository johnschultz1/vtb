#verilator verilate from sv to c++
$VERIHOME/bin/verilator --cc $VERIINC  \
 --binary $VERIOPTS -CFLAGS "-std=c++17 -lpthread "  \
 --Mdir $PROJECTSHOME/$PROJECTNAME/verif/run/vtb/ \
 -f $PROJECTSHOME/$PROJECTNAME/verif/src.f \
 -top-module TB 