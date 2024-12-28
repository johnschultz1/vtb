#verilator verilate from sv to c++
$VERIHOME/bin/verilator --cc $VERIINC  \
 --exe $PROJECTDIR/verif/main.cpp -CFLAGS "-std=c++17 -lprotobuf -lpthread "  \
 --build $VERIOPTS --Mdir $PROJECTDIR/verif/run/vtb/ \
 -f $PROJECTDIR/verif/src.f \
 -top-module TB 