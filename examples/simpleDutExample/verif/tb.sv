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
endmodule