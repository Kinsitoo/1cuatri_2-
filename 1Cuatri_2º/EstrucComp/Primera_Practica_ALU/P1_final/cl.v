module cl(output /*reg*/ wire out, input wire a, b, input wire [1:0] S);

  wire sA, sO, sX, sN;

  and and1(sA, a, b);
  or or1(sO, a, b);
  xor xor1(sX, a, b);
  not no1(sN, a);

  mux4_1 mux1(out, sA,  sO, sX, sN, S);

/* De forma conductual
  always @(a , b, S) begin
    case (S)
      2'b00: out = a & b;
      2'b01: out = a | b;
      2'b10: out = a ^ b;
      2'b11: out = ~a;
      default: out = 2'bX;
    endcase
  end
*/

endmodule