module TB;
    import scenarioPkg::*;
    import utilityPkg::*;
    import tbArchPkg::*;
    import typesPkg::*;

    dutWrapper dutWrap();

    initial begin
      cfgList_t cfg;
      scenarioPkg::vif = dutWrap.dutIf;
      cfg = readConfig();
      // read in scenario
      scenarioPkg::scenario = readScenario(cfg);
      // start scenario
      scenarioGen(scenarioPkg::scenario);
    end

    // VCD dump
    initial begin
      $dumpfile("waveform.vcd");
      $dumpvars(0, TB);      // Dump variables for the entire testbench hierarchy
    end

endmodule