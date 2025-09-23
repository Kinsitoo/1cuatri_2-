//Sumador completo (full-adder) de tres entradas de 1 bit realizado a partir de puertas l�gicas 
module fa_v1(output wire sum, output wire c_out, input wire a, input wire b, input wire c_in);
    
    ha_v1 semisumador1(.sum(s1), .carry(c1), .a(a), .b(b));
    ha_v1 semisumador2 (.sum(sum), .carry(c2), .a(s1), .b(c_in));
    or(c_out, c1, c2);

endmodule
