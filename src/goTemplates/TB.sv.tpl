// Generated SystemVerilog
module TB;
    import eventsPkg::*;
    import messageQPkg::*;

    dutInterface dutIf();
    {{$dutName := .GetName}}
    // Instantiate DUT
    {{$dutName}} DUT (
        {{- $maxName := maxNameWidth .Ports }}
        {{- range $index, $port := .Ports }}
        .{{ pad $port.GetName $maxName }} (dutIf.{{ pad $port.GetName $maxName }}){{ if lt $index (sub1 (len $.Ports)) }},{{ end }}
        {{- end }}
    );
endmodule