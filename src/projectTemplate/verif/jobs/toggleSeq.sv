class automatic toggleSeq;
    string id;
    //virtual dutInterface vif;


   // function new(string id, dutIf);
       // this.id =id;
      //  vif = dutIf;
  //  endfunction

      `startJob
     //`taskStart(toggleSeq)

        automatic  msg_t configuration = cfg; 
        bit sigInit;
        // init 
        $display(configuration.strings["SIG"]);
        sigInit = configuration.ints["SIGINIT"];
        vif.setDut(configuration.strings["SIG"],sigInit);
        #(configuration.ints["TOGGLEINITDELAY"]);
    
        // toggle forever
        if(configuration.bool["TOGGLEFOREVER"]) begin
            while(1) begin
                vif.setDut(configuration.strings["SIG"],~sigInit);
                sigInit = ~sigInit;
                #(configuration.ints["TOGGLEDELAY"]);
            end
        // toggle x # cycles
        end else if (configuration.ints.exists("TOGGLECYCLES")) begin
            repeat(configuration.ints["TOGGLECYCLES"]) begin
                vif.setDut(configuration.strings["SIG"],~sigInit);
                sigInit = ~sigInit;
                #(configuration.ints["TOGGLEDELAY"]);
            end
        // toggle once
        end else begin
            vif.setDut(configuration.strings["SIG"],~sigInit);
            sigInit = ~sigInit;
        end
      `endJob

endclass;