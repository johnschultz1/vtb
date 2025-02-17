class automatic predictor;

      `startJob
        // CONFIG INFO START
        // CONFIG INFO END

        logic [7:0] counter = 0;

        // dut counts every clk cycle
        while (1) begin
          // report change
          msg.ints["VALUE"] = counter;
          publishMsg(.jobName(name), .msg(msg));
          counter = counter +1;
          #10;
        end

      `endJob

endclass;