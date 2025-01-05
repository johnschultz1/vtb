class automatic monitor;

    msg_t msg;
    int value, oldValue;

      `startJob
        // CONFIG INFO START
        // SIG signal to monitor
        // MSGTYPE should be set to the name of the outgoing message type
        // CONFIG INFO END

        vif.getDut(cfg.strings["SIG"],value);
        oldValue = value;
        // publish init value
        msg.ints["VALUE"] = value;
        publishMsg(.jobName(name), .msg(msg));

        while (1) begin
            // wait for a signal to change
            while (value == oldValue) begin
                vif.getDut(cfg.strings["SIG"],value);
                #1;
            end
          // report change
          msg.ints["VALUE"] = value;
          $display("[%t][Monitor] %s updated, was: %h now: %h ", $realtime(), cfg.strings["SIG"], oldValue, value);
          publishMsg(.jobName(name), .msg(msg));
          oldValue = value;
        end

      `endJob

endclass;