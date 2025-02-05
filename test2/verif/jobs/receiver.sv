class receiver;

    `startJob
        automatic bit valid = 0;
        automatic stringList_t idList;
        static int count[string];

        idList = msg.stringList["ID"];

        foreach(idList[x]) begin
            automatic string ID = idList[x];
            if (ID == cfg.strings["ID"]) begin
                valid = 1;
                count[ID] = count[ID] +1;
                name = ID;
            end
        end

        if (valid == 1) begin
            $display($sformatf("MSG ACK From ID: %s received the following message:\n%s",cfg.strings["ID"], msg.strings["content"] ));
            $display($sformatf("Have Recieved %d messages in total", count[name]  ));
        end
    `endJob

endclass;