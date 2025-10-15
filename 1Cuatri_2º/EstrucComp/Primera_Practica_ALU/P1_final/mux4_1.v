// Multiplexor de 4 entradas y una salida de un bit
module mux4_1(output /*wire*/ reg out, input wire a, b, c ,d, input wire [1:0] S);

  always @(a, b, c, d, S) begin
    case (S)
      2'b00: out = a;
      2'b01: out = b;
      2'b10: out = c;
      2'b11: out = d; 
      default: out = 1'bX; 
    endcase
  end

/* Con assign
assign out =  (S == 2'b00) ? a : (S == 2'b01) ? b : (S == 2'b10) ? c : d; 
*/

endmodule