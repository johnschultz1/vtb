class automatic dataGen;

    bit [7:0] field1 = '0;
    bit [7:0] field2 = '0;
    bit [7:0] field3 = '0;
    bit [7:0] field4 = '0;

    `startJob
        // CONFIG INFO START
        // REPEAT : how much data to send out
        // CONFIG INFO END

        // dut counts every clk cycle
        repeat(cfg.ints["REPEAT"]) begin
            randomizeFields();
            $display("[%t][Data Gen] Generate Data Word: %h ", $realtime(), {field4, field3, field2, field1});
            msg.ints["DATA"] = {field4, field3, field2, field1};
            publishMsg(.jobName(name), .msg(msg));
        end

    `endJob

    function void randomizeFields();
      field1 = $urandom_range(0,3);
      field2 = $urandom_range(4,7);
      field3 = $urandom_range(8,11);
      field4 = $urandom_range(12,15);
    endfunction

endclass;