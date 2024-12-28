task automatic taskFactory(msgList_t msgList, msg_t cfg, string taskName, string id);
  case(taskName)
    {{- range $index, $task := .Tasks}}
    "{{$task.CallName}}":
      begin
        {{ $task.CallName }} {{ $task.CallName  }}_h = new();
        {{ $task.CallName  }}_h.startJob(.cfg(cfg), .msgs(msgList), .vif(scenarioPkg::vif));
      end
    {{- end}}
  default: $display($sformatf("ERROR, could not find task %s", taskName));
  endcase
endtask