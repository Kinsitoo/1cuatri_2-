`timescale 1 ns / 10 ps
module microc_tb;

// Declaración de variables
reg clk, reset, s_inc, s_inm, we3, wez;
reg [2:0] Op;
wire z;
wire [5:0] Opcode;

// Instanciación del camino de datos
microc micro(Opcode, z, clk, reset, s_inc, s_inm, we3, wez, Op);
// Opcode Salida Opcode (no la usamos en el testbench)
// z Salida flag zero (no la usamos en el testbench)
// clk Entrada clk
// reset Entrada reset
// s_inc Entrada control PC (proveniente de la UC simulada)
// s_inm Entrada control mux escritura (proveniente de la UC simulada)
// we3 Entrada habilitación escritura banco (proveniente de la UC simulada)
// wez Entrada habilitación escritura flag z (proveniente de la UC simulada)
// Op Entrada operación ALU (proveniente de la UC simulada)


// Generación de reloj clk
always
begin
  clk=1;
  #10;
  clk=0;
  #10;
end

 // Inicialización del testbench
  initial
    begin
      $dumpfile("microc_tb.vcd");
      $dumpvars(0, microc_tb); // Volcado de todas las variables del testbench

      // Inicializar señales de control
      s_inc = 1'b0; // Inicialmente, PC incrementa (aunque reset lo pondrá a 0)
      s_inm = 1'b0;
      we3 = 1'b0;
      wez = 1'b0; // Aunque no se use internamente
      Op = 3'b000;

     // --- Reset inicial ---
      reset = 1'b1;
      #5; // Espera un poco antes de desactivar reset
      reset = 1'b0;
      // Esperamos a que el PC salte a la dirección de 'Start' (0x0005) según el jmp en 0x0000
      #25; // Ajuste para que PC esté en 0x0005 al inicio del primer ciclo simulado de la UC.

       // --- Simulación del programa de ejemplo ---
      // Ciclo 1: PC=0x0000 -> j Start (Opcode: 0100_0000_0000_0101 -> Opcode=0x10)
      #10; s_inc = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; #10;

      // Ciclo 2: PC=0x0005 -> li#0 R2 (Opcode: 0001_0000_0000_0010 -> Opcode=0x04)
      #10; s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0; #10;

      // Ciclo 3: PC=0x0006 -> li#2 R1 (Opcode: 0001_0000_0010_0001 -> Opcode=0x04)
      #10; s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0; #10;

      // Ciclo 4: PC=0x0007 -> li#4 R3 (Opcode: 0001_0000_0100_0011 -> Opcode=0x04)
      #10; s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0; #10;

      // Ciclo 5: PC=0x0008 -> li#1 R4 (Opcode: 0001_0000_0001_0100 -> Opcode=0x04)
      #10; s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0; #10;

      // Ciclo 6: PC=0x0009 -> add R2 R3 R2 (Opcode: 1010_0010_0011_0010 -> Opcode=0x28)
      #10; s_inm = 1'b0; we3 = 1'b1; Op = 3'b010; s_inc = 1'b1; wez = 1'b1; #10;

      // Ciclo 7: PC=0x000A -> sub R1 R4 R1 (Opcode: 1011_0001_0100_0001 -> Opcode=0x2C)
      #10; s_inm = 1'b0; we3 = 1'b1; Op = 3'b011; s_inc = 1'b1; wez = 1'b1; #10;

      // Ciclo 8: PC=0x000B -> jnz Iter (Opcode: 0100_1000_0000_1001 -> Opcode=0x12)
      #10; s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; #10;

      // Ciclo 9: PC=0x0009 -> add R2 R3 R2 (Opcode: 1010_0010_0011_0010)
      #10; s_inm = 1'b0; we3 = 1'b1; Op = 3'b010; s_inc = 1'b1; wez = 1'b1; #10;

      // Ciclo 10: PC=0x000A -> sub R1 R4 R1 (Opcode: 1011_0001_0100_0001)
      #10; s_inm = 1'b0; we3 = 1'b1; Op = 3'b011; s_inc = 1'b1; wez = 1'b1; #10;

      // Ciclo 11: PC=0x000B -> jnz Iter (Opcode: 0100_1000_0000_1001)
      #10; s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b1; wez = 1'b0; #10;

      // Ciclo 12: PC=0x000C -> j Fin (Opcode: 0100_0000_0000_1100 -> Opcode=0x10)
      #10; s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; #10;

      // Ciclo 13: PC=0x000C -> j Fin (Opcode: 0100_0000_0000_1100)
      #10; s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; #10;

      // Ciclo 14: PC=0x000C -> j Fin (Opcode: 0100_0000_0000_1100)
      #10; s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; #10;

      $finish;
    end

endmodule