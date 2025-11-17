module microc(output wire [5:0] Opcode, output wire z, input wire clk, reset, s_inc, s_inm, we3, wez, input wire [2:0] Op);
//Microcontrolador sin memoria de datos de un solo ciclo
wire [7:0] rd1, rd2, wd3, alu_out;    
wire [15:0] instruccion;
wire [9:0] pc_out, pc_in, dir_salto, sum_out;
wire zero_flag_alu;

assign dir_salto = instruccion[9:0];

memprog memoria(instruccion, clk, pc_out);

registro #(10) PC(pc_out, clk, reset, pc_in);

regfile Banco_reg(rd1, rd2, clk, we3, instruccion[3:0], instruccion[11:8], instruccion[7:4], wd3);

alu ALU(alu_out, z, rd1, rd2, Op);

sum sumador(sum_out, pc_out, 10'd1);

// Mux de la izq 
mux2 #(10) mux1(pc_in, sum_out, instruccion[9:0], s_inc);

// Mux de la derecha
mux2 #(8) mux3(wd3, alu_out, instruccion[11:4], s_inm);

ffd FFZ(clk, reset, zero_flag_alu, wez, z);

assign Opcode = instruccion[15:10];

endmodule
