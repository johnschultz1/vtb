task automatic jobFactory(msg_t msgList, msg_t cfg, string jobName, string jobInstName);
  case(jobName)
    "inOrderScoreBoard":
      begin
        inOrderScoreBoard inOrderScoreBoard_h = new();
        inOrderScoreBoard_h.startJob(.cfg(cfg), .msg(msgList), .vif(scenarioPkg::vif), .name(jobInstName));
      end
    "monitor":
      begin
        monitor monitor_h = new();
        monitor_h.startJob(.cfg(cfg), .msg(msgList), .vif(scenarioPkg::vif), .name(jobInstName));
      end
    "predictor":
      begin
        predictor predictor_h = new();
        predictor_h.startJob(.cfg(cfg), .msg(msgList), .vif(scenarioPkg::vif), .name(jobInstName));
      end
    "delay":
      begin
        delay delay_h = new();
        delay_h.startJob(.cfg(cfg), .msg(msgList), .vif(scenarioPkg::vif), .name(jobInstName));
      end
    "toggleSeq":
      begin
        toggleSeq toggleSeq_h = new();
        toggleSeq_h.startJob(.cfg(cfg), .msg(msgList), .vif(scenarioPkg::vif), .name(jobInstName));
      end
  default: $display($sformatf("ERROR, could not find job %s", jobName));
  endcase
endtask