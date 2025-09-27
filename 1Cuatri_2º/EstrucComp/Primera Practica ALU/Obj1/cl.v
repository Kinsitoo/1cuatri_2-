module cl(output wire out, input wire a, b, input wire [1:0] S);

  always @(a, b) begin
    case (S)
    2'b00 : out = a & b;
    2'b01 : out = a | b;
    2'b10 : out = a ^ b;
    2'b11 : out = ~a;
    default : out = a;
  end

endmodule