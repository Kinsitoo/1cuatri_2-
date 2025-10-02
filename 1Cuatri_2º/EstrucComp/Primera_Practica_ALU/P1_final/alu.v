module alu(output wire [3:0] R, output wire zero, carry, sign, input wire [3:0] A, B, input wire c_in, input wire [2:0] Op);

  wire [3:0] cable_Op1, cable_Op2, cable_sum, cable_ul4;

  sum4_v1 sumador(cable_sum, carry, cable_Op1, cable_Op2, c_in);
  ul4 u_logica(cable_ul4, cable_Op1, cable_Op2, Op[1:0]);
  mux2_4 mux(R, cable_sum, cable_ul4, Op[2]);

  assign zero = R ? 1'b0 : 1'b1;
  assign sign = R[3];

  // iverilog alu.v preprocess.v compl1.v sum4_v1.v fa.v u14.v cl.v mux4_1.v mux2_4.v
  // iverilog alu_tb.v alu.v prep.v compl1.v sum.v fa.v u14.v cl.v mux4_1.v mux2_4.v

endmodule