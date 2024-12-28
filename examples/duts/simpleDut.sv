module simpleDut(

  input clk,
  input rst,

  input logic i_bitSignal1,
  input logic i_bitSignal2,
  input logic [31:0] i_bit32Signal1,
  input logic [7:0] i_bit8Signal2,

  output logic o_bitSignal1,
  output logic o_bitSignal2,
  output logic [31:0] o_bit32Signal1,
  output logic [7:0]  o_bit8Signal2
);



  bit [7:0] counter;

  always @(posedge clk) begin
      if (rst == 0) begin
        counter = 0;
        o_bitSignal1 = 0;
        o_bitSignal1 = 1;
      end else begin
        o_bitSignal1    = ~o_bitSignal1;
        o_bitSignal2    = ~o_bitSignal2;
        o_bit32Signal1  = $urandom();
        o_bit8Signal2   = counter;
        counter = counter + 1;
      end
  end

endmodule