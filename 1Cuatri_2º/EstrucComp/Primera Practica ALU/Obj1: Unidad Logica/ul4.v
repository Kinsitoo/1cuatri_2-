//Unidad lógica de 4 bits de forma estructural
module ul4(output wire [3:0] Out, input wire [3:0] A, input wire [3:0] B, input wire [1:0] S);
  
  module and4 (output [3:0] Z, input wire [3:0] A, input wire [3:0] B);

    assign Z = A & B;

  endmodule

  module or4 (output [3:0] Z, input wire [3:0] A, input wire [3:0] B);

    assign Z = A | B;

  endmodule

  module xor4 (output [3:0] Z, input wire [3:0] A, input wire [3:0] B);

    assign Z = A ^ B;

  endmodule

  module inversor4 (output [3:0] Z, input wire [3:0] A;

    assign Z = ~A;

  endmodule

endmodule