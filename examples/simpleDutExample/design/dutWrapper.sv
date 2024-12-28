module dutWrapper();

    dutInterface dutIf();
    simpleDut DUT (.*);

    // signals    
    logic       clk           ;
    logic       rst           ;
    logic       i_bitSignal1  ;
    logic       i_bitSignal2  ;
    logic[31:0] i_bit32Signal1;
    logic[7:0]  i_bit8Signal2 ;
    logic       o_bitSignal1  ;
    logic       o_bitSignal2  ;
    logic[31:0] o_bit32Signal1;
    logic[7:0]  o_bit8Signal2 ;

    // interface + DUT connection
    // currently verilator doesnt support virtual interface tracing
    // the interface driving is still functional without this, but will not be visible on wave
    always @ ( 
        dutIf.clk           , 
        dutIf.rst           , 
        dutIf.i_bitSignal1  , 
        dutIf.i_bitSignal2  , 
        dutIf.i_bit32Signal1, 
        dutIf.i_bit8Signal2 ,
        DUT.o_bitSignal1  ,
        DUT.o_bitSignal2  ,
        DUT.o_bit32Signal1,
        DUT.o_bit8Signal2 
    ) begin  
            force DUT.clk              = dutIf.clk           ;  
            force DUT.rst              = dutIf.rst           ;  
            force DUT.i_bitSignal1     = dutIf.i_bitSignal1  ;  
            force DUT.i_bitSignal2     = dutIf.i_bitSignal2  ;  
            force DUT.i_bit32Signal1   = dutIf.i_bit32Signal1;  
            force DUT.i_bit8Signal2    = dutIf.i_bit8Signal2 ;
            force dutIf.o_bitSignal1   = DUT.o_bitSignal1  ;
            force dutIf.o_bitSignal2   = DUT.o_bitSignal2  ;
            force dutIf.o_bit32Signal1 = DUT.o_bit32Signal1;
            force dutIf.o_bit8Signal2  = DUT.o_bit8Signal2 ;
    end
endmodule