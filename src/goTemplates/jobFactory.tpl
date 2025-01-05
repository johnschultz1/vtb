task automatic jobFactory(msg_t msgList, msg_t cfg, string jobName, string jobInstName);
  case(jobName)
    {{- range $index, $job := .Jobs}}
    "{{$job.CallName}}":
      begin
        {{ $job.CallName }} {{ $job.CallName  }}_h = new();
        {{ $job.CallName  }}_h.startJob(.cfg(cfg), .msg(msgList), .vif(scenarioPkg::vif), .name(jobInstName));
      end
    {{- end}}
  default: $display($sformatf("ERROR, could not find job %s", jobName));
  endcase
endtask