class automatic driver;

    `startJob
        // CONFIG INFO START
        // SIG : which signal to drive
        // CONFIG INFO END
        $display("[%t][Driver] Driving %s to: %h ", $realtime(), cfg.strings["SIG"], msg.ints["DATA"]);
        vif.setDut(cfg.strings["SIG"], msg.ints["DATA"]);
        vif.waitForPosEdgeDut(cfg.strings["CLK"]);

    `endJob

endclass;