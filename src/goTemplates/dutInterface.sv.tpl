interface dutInterface;
    {{- $maxDir := 6 }}         {{/* Fixed width for "input"/"output" */}}
    {{- $maxType := maxTypeWidth .Ports }}
    {{- $maxName := maxNameWidth .Ports }}      {{/* Maximum width of port names */}}
    {{- $maxLabel := add $maxName 2 }}          {{/* maxPortName + 2 (colon + space) */}}
    {{- $maxAssign := add $maxName 13 }}        {{/* maxPortName + 13 ( = value[31:0]) */}}

    // Declare ports
    {{- range .Ports }}
    {{ pad .GetType $maxType }} {{ pad .GetName $maxName }};
    {{- end }}

    // Task to set values dynamically
    task setDut(input string port_name, input logic [31:0] value);
        case (port_name)
            {{- range .Ports }}
            {{- if eq (getDirection .GetDir) "input" }}
            {{ pad (printf "\"%s\":" .GetName) $maxLabel }} {{ pad .GetName $maxName }} = {{ pad (extractBits .GetType "value") 11 }};
            {{- end }}
            {{- end }}
            default: $error("Invalid input port name: %s", port_name);
        endcase
    endtask

    // Task to get values dynamically
    task getDut(input string port_name, output logic [31:0] value);
        case (port_name)
            {{- range .Ports }}
            {{ pad (printf "\"%s\":" .GetName) $maxLabel }} value = {{ pad (zeroExtend .GetName .GetType) 10 }};
            {{- end }}
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal
    task waitOnDut(input string port_name, output logic [31:0] value);
        case (port_name)
            {{- range .Ports }}
            {{ pad (printf "\"%s\":" .GetName) $maxLabel }} wait({{ pad (zeroExtend .GetName .GetType) 10 }} == value);
            {{- end }}
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal edge
    task waitForPosEdgeDut(input string port_name, input bit idx=0);
        case (port_name)
            {{- range .Ports }}
                {{- if or (eq .GetType "logic") (eq .GetType "bit") }}
                    {{ pad (printf "\"%s\":" .GetName) $maxLabel }} @(posedge {{.GetName}});
                {{- else}}
                    {{ pad (printf "\"%s\":" .GetName) $maxLabel }} @(posedge {{.GetName}}[idx-:1]);
                {{- end}}
            {{- end }}
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal edge
    task waitForNegEdgeDut(input string port_name, input bit idx=0);
        case (port_name)
            {{- range .Ports }}
                {{- if or (eq .GetType "logic") (eq .GetType "bit") }}
                    {{ pad (printf "\"%s\":" .GetName) $maxLabel }} @(negedge {{.GetName}});
                {{- else}}
                    {{ pad (printf "\"%s\":" .GetName) $maxLabel }} @(negedge {{.GetName}}[idx-:1]);
                {{- end}}
            {{- end }}
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

    // Task to wait on a Dut Signal to equal a value
    task waitOnSig(input string port_name, input int value);
        case (port_name)
            {{- range .Ports }}
                {{ pad (printf "\"%s\":" .GetName) $maxLabel }} wait({{.GetName}} == value);
            {{- end }}
            default: $error("Invalid output port name: %s", port_name);
        endcase
    endtask

endinterface