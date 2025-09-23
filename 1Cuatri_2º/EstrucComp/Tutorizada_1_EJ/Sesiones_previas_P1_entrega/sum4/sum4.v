//Sumador de 4 bits 
module sum4(output wire[3:0] S, output wire c_out, input wire[3:0] A, input wire[3:0] B, input wire c_in);
	// Contenido

	fa_vr sumador1(.sum(S[0]), .c_out(c1) , .a(A[0]), .b(B[0]), .c_in(c_in));
	fa_vr sumador2(.sum(S[1]), .c_out(c2) , .a(A[1]), .b(B[1]), .c_in(c1));
	fa_vr sumador3(.sum(S[2]), .c_out(c3) , .a(A[2]), .b(B[2]), .c_in(c2));
	fa_vr sumador4(.sum(S[3]), .c_out(c_out) , .a(A[3]), .b(B[3]), .c_in(c3));
	
endmodule

