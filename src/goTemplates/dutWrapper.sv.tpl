module dutWrapper();
    {{- $dutName := .GetName }}

    dutInterface dutIf();
    {{$dutName}} DUT (.*);

    // signals
    {{- $maxDir := 6 }}    {{/* Fixed width for "input"/"output" */}}
    {{- $maxType := maxTypeWidth .Ports }}
    {{- $maxName := maxNameWidth .Ports }}
    {{- range $index, $port := .Ports }}
    {{ pad $port.GetType $maxType }} {{ pad $port.GetName $maxName }};
    {{- end }}

    // interface + DUT connection
    // currently verilator doesnt support virtual interface tracing
    // the interface driving is still functional without this, but will not be visible on wave
    always @ (
    {{- range $index, $port := .Ports }}
      {{- if eq $port.GetDir "In"}} 
        dutIf.{{ pad $port.GetName $maxName }}{{ if lt $index (sub1 (len $.Ports)) }},{{ end }}
      {{- else }}
        DUT.{{ pad $port.GetName $maxName }}{{ if lt $index (sub1 (len $.Ports)) }},{{ end }}
      {{- end }}
    {{- end }}
    ) begin 
      {{- range $index, $port := .Ports }}
          {{- if eq $port.GetDir "In"}}  
            force DUT.{{ pad $port.GetName $maxName }}   = dutIf.{{ pad $port.GetName $maxName }};
          {{- else }}
            force dutIf.{{ pad $port.GetName $maxName }} = DUT.{{ pad $port.GetName $maxName }};              
          {{- end }}
      {{- end }}
    end
endmodule