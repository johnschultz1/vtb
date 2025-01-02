task automatic jobFactory(msgList_t msgList, msg_t cfg, string jobName, string id);
  case(jobName)
    {{- range $index, $job := .Jobs}}
    "{{$job.CallName}}":
      begin
        {{ $job.CallName }} {{ $job.CallName  }}_h = new();
        {{ $job.CallName  }}_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
    {{- end}}
  default: $display($sformatf("ERROR, could not find job %s", jobName));
  endcase
endtask