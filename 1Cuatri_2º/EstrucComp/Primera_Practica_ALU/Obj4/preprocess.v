module preprocess(output wire [3:0] AMod, output wire [3:0] BMod, input wire [3:0] A, input wire [3:0] B, input wire [2:0] Op);

  wire add1, op1_A, op2_B, cpl;
  wire [3:0] cable1, cable2;
  reg cpl;

  assign add1 = Op[0];
  assign op1_A = Op[2] | (Op[1] & ~Op[0]);
  assign op2_B = Op[2] | (Op[1] & ~Op[0]);
  //assign cpl = (~Op[2] & ~Op[1]) & Op[0];

  always @(*) begin
  cpl = ((~Op[2] & ~Op[1]) & Op[0]);
  end

  mux2_4 mux1(cable1, 4'b0, 4'b1, add1);                   // add1
  mux2_4 mux2(AMod, cable1, A, op1_A);                     // op1_A
  mux2_4 mux3(cable2, A, B, op2_B);                        // op2_B
  compl1 C1(BMod, cable2, cpl);                            // C1

endmodule