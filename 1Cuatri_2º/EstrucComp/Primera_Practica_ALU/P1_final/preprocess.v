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

  mux2_4 mux1(cable1, 4'b0, 4'b1, add1);                   // add1
  mux2_4 mux2(AMod, cable1, A, op1_A);                     // op1_A
  mux2_4 mux3(cable2, A, B, op2_B);                        // op2_B
  compl1 cpl(BMod, cable2, cp1);                           // Cpl

endmodule


/*

Operacion   Op2   Op1   Op0   Add1    Op1_A   Op2_B   Cpl
A+B+c_in    0     0     0     X       1       1       0
A+1+c_in    0     0     1     1       0       0       0
-A+c_in     0     1     0     1       0       0       1
-B+c_in     0     1     1     1       0       1       1
A and B     1     0     0     X       1       1       0
a or B      1     0     1     X       1       1       0
A xor B     1     1     0     X       1       1       0
Not A       1     1     1     X       X       1       X
A+A+c_in                      X       1       0       0
B+1+c_in                      1       0       1       0
a+c_in                        0       0       0       0
b+c_in                        0       0       1       0
*/