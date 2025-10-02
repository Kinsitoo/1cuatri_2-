module cl(output wire out, input wire a, b, input wire [1:0] S);

  wire sA, sO, sX, sN;

  and and1(sA, a, b);
  or or1(sO, a, b);
  xor xor1(sX, a, b);
  not no1(sN, a);

  mux4_1 mux1(out, sA, sO, sX, sN, S);

endmodule