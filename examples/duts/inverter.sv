module inverter(
  input  logic bit A,
  output logic bit B
);
  assign B = ~A;
endmodule