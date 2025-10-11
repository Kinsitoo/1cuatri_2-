module preprocess(output wire [3:0] AMod, output wire [3:0] BMod, input wire [3:0] A, input wire [3:0] B, input wire [2:0] Op);

  wire add1, op1_A, op2_B, cp1;
  wire [3:0] cable1, cable2;
  //reg cpl;

  assign add1 = 1'b1;
  assign op1_A = Op[2] |(~Op[1] & ~Op[0]);
  assign op2_B = Op[2] | (~Op[1] & ~Op[0]) | (Op[1] & Op[0]);
  assign cp1 = ~Op[2] & Op[1];

  /*always @(*) begin
  cp1 = ~Op[2] & Op[1];
  end
  */

  mux2_4 mux1(cable1, 4'b0, 4'b1, add1);             // add1
  mux2_4 mux2(AMod, cable1, A, op1_A);                     // op1_A
  mux2_4 mux3(cable2, A, B, op2_B);                        // op2_B
  compl1 cpl(BMod, cable2, cp1);                           // Cpl

endmodule