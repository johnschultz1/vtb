task automatic taskFactory(msgList_t msgList, msg_t cfg, string taskName, string id);
  case(taskName)
    "delay":
      begin
        delay delay_h = new();
        delay_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
    "toggleSeq":
      begin
        toggleSeq toggleSeq_h = new();
        toggleSeq_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
    "helloHuman":
      begin
        helloHuman helloHuman_h = new();
        helloHuman_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
    "broadcaster":
      begin
        broadcaster broadcaster_h = new();
        broadcaster_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
    "receiver":
      begin
        receiver receiver_h = new();
        receiver_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
  default: $display($sformatf("ERROR, could not find task %s", taskName));
  endcase
endtask