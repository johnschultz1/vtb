#verilator verilate from sv to c++
$VERIHOME/bin/verilator --cc $VERIINC  \
 --binary $VERIOPTS -CFLAGS "-std=c++17 -lprotobuf -lpthread "  \
 --Mdir $PROJECTDIR/verif/run/vtb/ \
 -f $PROJECTDIR/verif/src.f \
 -top-module TB 