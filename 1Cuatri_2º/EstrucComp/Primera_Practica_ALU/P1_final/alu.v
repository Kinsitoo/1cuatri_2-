module alu(output wire [3:0] R, output wire zero, carry, sign, input wire [3:0] A, B, input wire c_in, input wire [2:0] Op);

  wire [3:0] cable_Op1, cable_Op2, cable_sum, cable_ul4;

  preprocess preprocesador(cable_Op1, cable_Op2, A, B, Op);
  sum4_v1 sumador(cable_sum, carry, cable_Op1, cable_Op2, c_in);
  ul4 u_logica(cable_ul4, cable_Op1, cable_Op2, Op[1:0]);
  mux2_4 mux(R, cable_sum, cable_ul4, Op[2]);
  

  assign zero = R ? 1'b0 : 1'b1;
  assign sign = R[3];
  
endmodule

  // iverilog -o test_alu alu_tb.v compl1.v mux2_4.v preprocess.v sum4_v1.v ul4.v alu.v cl.v fa.v mux4_1.v
  // vvp test_alu
  // gtkwave alu.vcd

