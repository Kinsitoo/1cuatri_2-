module mux2_4(output wire /*reg*/ [3:0] Out, input  wire [3:0] A, input wire [3:0] B, input wire s);

  assign Out = s ? B : A;

/* De forma conductual
  always @(*) begin
    case(s)
      1'b0 : Out = A;
      1'b1 : Out = B;
      default : Out = 1'bX;
    endcase
  end
*/

endmodule