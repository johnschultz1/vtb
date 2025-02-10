class broadcaster;

    `startJob

        repeat (10) begin
            msg.strings["content"] = cfg.strings["content"];
            msg.stringList["ID"]   = cfg.stringList["ID"];
            msg.msgType = cfg.strings[name];
            //#1;
            publishMsg(.jobName(name), .msg(msg));
            //#1;
        end

        //#1;
    `endJob

endclass;