import VtbPkg::*;
import typesPkg::*;
class automatic inOrderScoreBoard;
    static msg_t msgA[$];
    static msg_t msgB[$];
    msg_t msgACompare;
    msg_t msgBCompare;
    static string msgAName = "";
    static string msgBName = "";
    static int passCount;
    static int failCount;

      `startJob
        // CONFIG INFO START
        // CONFIG INFO END

        // push received messages to Qs
        if (msg.strings["NAME"] == msgAName) msgA.push_back(msg);
        if (msg.strings["NAME"] == msgBName) msgB.push_back(msg);
        if (msg.strings["NAME"] != msgAName && msg.strings["NAME"] != msgBName && msgAName == "") begin 
            msgAName = msg.strings["NAME"];
            msgA.push_back(msg);
        end
        if (msg.strings["NAME"] != msgAName && msg.strings["NAME"] != msgBName && msgBName == "") begin 
            msgBName = msg.strings["NAME"];
            msgB.push_back(msg);
        end

        // check if there are transactions in each of the Qs to check
        if(msgA.size() != 0 && msgB.size() != 0) begin
            automatic bit pass;
            msgACompare = msgA.pop_front();
            msgBCompare = msgB.pop_front();

            pass = utilityPkg::compareMsg(msgACompare, msgBCompare);
            if (pass == 0) begin
                failCount = failCount + 1;
                $display("[%t][ScoreBoard] error, scoreboard mismatch", $realtime());
            end else begin
                passCount = passCount + 1;
                $display("[%t][ScoreBoard] MATCH: %s msg = %s msg ", $realtime(), msgAName, msgBName);
            end
        end

      `endJob

    function void report();
        $display("[%t][ScoreBoard] PASSCOUNT: %d FAILCOUNT: %d", $realtime(), passCount, failCount);
    endfunction

endclass;