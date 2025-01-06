interface dutInterface;                                 

    // Declare ports
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

    // Task to set values dynamically
    task setDut(input string port_name, input logic [31:0] value);
        case (port_name)
            "clk":           clk            = value[0]   ;
            "rst":           rst            = value[0]   ;
            "i_bitSignal1":  i_bitSignal1   = value[0]   ;
            "i_bitSignal2":  i_bitSignal2   = value[0]   ;
            "i_bit32Signal1": i_bit32Signal1 = value[31:0];
            "i_bit8Signal2": i_bit8Signal2  = value[7:0] ;
            default: $error("Invalid input port name: %s", port_name);
        endcase
    endtask

    // Task to get values dynamically
    task getDut(input string port_name, output logic [31:0] value);
        case (port_name)
            "clk":           value = {31'b0, clk};
            "rst":           value = {31'b0, rst};
            "i_bitSignal1":  value = {31'b0, i_bitSignal1};
            "i_bitSignal2":  value = {31'b0, i_bitSignal2};
            "i_bit32Signal1": value = i_bit32Signal1;
            "i_bit8Signal2": value = {24'b0, i_bit8Signal2};
            "o_bitSignal1":  value = {31'b0, o_bitSignal1};
            "o_bitSignal2":  value = {31'b0, o_bitSignal2};
            "o_bit32Signal1": value = o_bit32Signal1;
            "o_bit8Signal2": value = {24'b0, o_bit8Signal2};
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal
    task waitOnDut(input string port_name, output logic [31:0] value);
        case (port_name)
            "clk":           wait({31'b0, clk} == value);
            "rst":           wait({31'b0, rst} == value);
            "i_bitSignal1":  wait({31'b0, i_bitSignal1} == value);
            "i_bitSignal2":  wait({31'b0, i_bitSignal2} == value);
            "i_bit32Signal1": wait(i_bit32Signal1 == value);
            "i_bit8Signal2": wait({24'b0, i_bit8Signal2} == value);
            "o_bitSignal1":  wait({31'b0, o_bitSignal1} == value);
            "o_bitSignal2":  wait({31'b0, o_bitSignal2} == value);
            "o_bit32Signal1": wait(o_bit32Signal1 == value);
            "o_bit8Signal2": wait({24'b0, o_bit8Signal2} == value);
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal edge
    task waitForPosEdgeDut(input string port_name, input bit idx=0);
        case (port_name)
                    "clk":           @(posedge clk);
                    "rst":           @(posedge rst);
                    "i_bitSignal1":  @(posedge i_bitSignal1);
                    "i_bitSignal2":  @(posedge i_bitSignal2);
                    "i_bit32Signal1": @(posedge i_bit32Signal1[idx-:1]);
                    "i_bit8Signal2": @(posedge i_bit8Signal2[idx-:1]);
                    "o_bitSignal1":  @(posedge o_bitSignal1);
                    "o_bitSignal2":  @(posedge o_bitSignal2);
                    "o_bit32Signal1": @(posedge o_bit32Signal1[idx-:1]);
                    "o_bit8Signal2": @(posedge o_bit8Signal2[idx-:1]);
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal edge
    task waitForNegEdgeDut(input string port_name, input bit idx=0);
        case (port_name)
                    "clk":           @(negedge clk);
                    "rst":           @(negedge rst);
                    "i_bitSignal1":  @(negedge i_bitSignal1);
                    "i_bitSignal2":  @(negedge i_bitSignal2);
                    "i_bit32Signal1": @(negedge i_bit32Signal1[idx-:1]);
                    "i_bit8Signal2": @(negedge i_bit8Signal2[idx-:1]);
                    "o_bitSignal1":  @(negedge o_bitSignal1);
                    "o_bitSignal2":  @(negedge o_bitSignal2);
                    "o_bit32Signal1": @(negedge o_bit32Signal1[idx-:1]);
                    "o_bit8Signal2": @(negedge o_bit8Signal2[idx-:1]);
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal to equal a value
    task waitOnSig(input string port_name, input int value);
        case (port_name)
                "clk":           wait(clk == value);
                "rst":           wait(rst == value);
                "i_bitSignal1":  wait(i_bitSignal1 == value);
                "i_bitSignal2":  wait(i_bitSignal2 == value);
                "i_bit32Signal1": wait(i_bit32Signal1 == value);
                "i_bit8Signal2": wait(i_bit8Signal2 == value);
                "o_bitSignal1":  wait(o_bitSignal1 == value);
                "o_bitSignal2":  wait(o_bitSignal2 == value);
                "o_bit32Signal1": wait(o_bit32Signal1 == value);
                "o_bit8Signal2": wait(o_bit8Signal2 == value);
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

endinterface