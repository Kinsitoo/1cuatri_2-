module compl1 (output wire [3:0] Out, input wire [3:0] Inp, input wire cp1);

  assign Out = cp1 ? Inp : ~Inp;

endmodule