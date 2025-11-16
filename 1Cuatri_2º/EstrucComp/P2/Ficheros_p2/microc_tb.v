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
      // El programa comienza en 0x0005 (Start: li#0 R2)
      // Ciclo 1: PC=0x0005 -> li#0 R2 (Opcode: 0001_0000_0000_0010 -> Opcode=0x04, C=0x0, Rd=2)
      #10; // Espera a mitad del ciclo para simular decodificación
      // Instrucción 'li': Carga constante inmediata. Selecciona inmediato para escribir, habilita escritura en banco, no actualiza z, PC avanza.
      // s_inm=1: Elige la constante de la instrucción (instruccion[11:4]=0x00) para wd3.
      // we3=1: Habilita la escritura en el banco de registros.
      // Op=000: No relevante para 'li', puede ser cualquier valor, aquí 000.
      // s_inc=1: Elige PC+1 para el próximo valor del PC.
      // wez=0: No actualiza el flag z.
      s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0;
      #10; // Finaliza ciclo 1

      // Ciclo 2: PC=0x0006 -> li#2 R1 (Opcode: 0001_0000_0010_0001 -> Opcode=0x04, C=0x2, Rd=1)
      #10;
      // Instrucción 'li': Igual que ciclo 1, pero carga C=0x2 en Rd=1.
      s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0;
      #10; // Finaliza ciclo 2

      // Ciclo 3: PC=0x0007 -> li#4 R3 (Opcode: 0001_0000_0100_0011 -> Opcode=0x04, C=0x4, Rd=3)
      #10;
      // Instrucción 'li': Igual que ciclo 1, pero carga C=0x4 en Rd=3.
      s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0;
      #10; // Finaliza ciclo 3

      // Ciclo 4: PC=0x0008 -> li#1 R4 (Opcode: 0001_0000_0001_0100 -> Opcode=0x04, C=0x1, Rd=4)
      #10;
      // Instrucción 'li': Igual que ciclo 1, pero carga C=0x1 en Rd=4.
      s_inm = 1'b1; we3 = 1'b1; Op = 3'b000; s_inc = 1'b1; wez = 1'b0;
      #10; // Finaliza ciclo 4

      // Ciclo 5: PC=0x0009 -> add R2 R3 R2 (Opcode: 1010_0010_0011_0010 -> Opcode=0x28, R1=2, R2=3, Rd=2, Op=000)
      #10;
      // Instrucción 'add': Operación ALU. Selecciona salida de ALU para escribir, habilita escritura en banco, actualiza z, PC avanza.
      // s_inm=0: Elige la salida de la ALU (alu_out) para wd3.
      // we3=1: Habilita la escritura en el banco de registros.
      // Op=000: Indica a la ALU que realice una suma (A + B). Segun PDF, bits 14-12 de la instruccion 'add' son 000.
      // s_inc=1: Elige PC+1 para el próximo valor del PC.
      // wez=1: Actualiza el flag z con el valor calculado por la ALU (zero).
      s_inm = 1'b0; we3 = 1'b1; Op = 3'b010; s_inc = 1'b1; wez = 1'b1; // Op=000 para add segun PDF
      #10; // Finaliza ciclo 5

      // Ciclo 6: PC=0x000A -> sub R1 R4 R1 (Opcode: 1011_0001_0100_0001 -> Opcode=0x2C, R1=1, R2=4, Rd=1, Op=011)
      #10;
      // Instrucción 'sub': Operación ALU. Selecciona salida de ALU para escribir, habilita escritura en banco, actualiza z, PC avanza.
      // s_inm=0: Elige la salida de la ALU (alu_out) para wd3.
      // we3=1: Habilita la escritura en el banco de registros.
      // Op=011: Indica a la ALU que realice una resta (A - B). Segun PDF, bits 14-12 de la instruccion 'sub' son 011.
      // s_inc=1: Elige PC+1 para el próximo valor del PC.
      // wez=1: Actualiza el flag z con el valor calculado por la ALU (zero).
      s_inm = 1'b0; we3 = 1'b1; Op = 3'b011; s_inc = 1'b1; wez = 1'b1; // Op=011 para sub segun PDF
      #10; // Finaliza ciclo 6

      // Ciclo 7: PC=0x000B -> jnz Iter (Opcode: 0100_1000_0000_1001 -> Opcode=0x12, D=0x0009)
      // La UC ve Opcode=0x12. Comprueba z (z=0, asumiendo R1 != 0 tras sub).
      // Como z=0 (R1 != 0), debe saltar: s_inc=0, PC=D (0x0009).
      #10;
      // Instrucción 'jnz': Salto condicional. No escribe en banco, no usa ALU, actualiza PC condicionalmente.
      // s_inm=0: No relevante si no escribe.
      // we3=0: No escribe en el banco de registros.
      // Op=000: No relevante si no usa ALU.
      // s_inc=0: Elige la dirección de salto (instruccion[9:0]=0x009) para el próximo valor del PC.
      // wez=0: No actualiza el flag z.
      s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; // Salta a Iter (0x0009)
      #10; // Finaliza ciclo 7

      // Ciclo 8: PC=0x0009 -> add R2 R3 R2 (Opcode: 1010_0010_0011_0010)
      #10;
      // Instrucción 'add': Igual que ciclo 5.
      s_inm = 1'b0; we3 = 1'b1; Op = 3'b010; s_inc = 1'b1; wez = 1'b1; // Op=000 para add
      #10; // Finaliza ciclo 8

      // Ciclo 9: PC=0x000A -> sub R1 R4 R1 (Opcode: 1011_0001_0100_0001)
      #10;
      // Instrucción 'sub': Igual que ciclo 6.
      s_inm = 1'b0; we3 = 1'b1; Op = 3'b011; s_inc = 1'b1; wez = 1'b1; // Op=011 para sub
      // En este ciclo, R1 se decrementa a 0, por lo que z debería cambiar a 1 tras la ALU.
      #10; // Finaliza ciclo 9

      // Ciclo 10: PC=0x000B -> jnz Iter (Opcode: 0100_1000_0000_1001)
      // La UC ve Opcode=0x12. Comprueba z (z=1, asumiendo R1 == 0 tras sub del ciclo 9).
      // Como z=1 (R1 == 0), NO salta: s_inc=1, PC=PC+1 (0x000C).
      #10;
      // Instrucción 'jnz': Salto condicional. No escribe en banco, no usa ALU, actualiza PC condicionalmente.
      // s_inm=0: No relevante si no escribe.
      // we3=0: No escribe en el banco de registros.
      // Op=000: No relevante si no usa ALU.
      // s_inc=1: Elige PC+1 para el próximo valor del PC.
      // wez=0: No actualiza el flag z.
      s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b1; wez = 1'b0; // No salta, PC=0x000C
      #10; // Finaliza ciclo 10

      // Ciclo 11: PC=0x000C -> j Fin (Opcode: 0100_0000_0000_1100 -> Opcode=0x10, D=0x000C)
      // La UC ve Opcode=0x10. Debe saltar incondicionalmente a D (0x000C).
      #10;
      // Instrucción 'j': Salto incondicional. No escribe en banco, no usa ALU, actualiza PC.
      // s_inm=0: No relevante si no escribe.
      // we3=0: No escribe en el banco de registros.
      // Op=000: No relevante si no usa ALU.
      // s_inc=0: Elige la dirección de salto (instruccion[9:0]=0x00C) para el próximo valor del PC.
      // wez=0: No actualiza el flag z.
      s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; // Salta a Fin (0x000C) - Bucle infinito
      #10; // Finaliza ciclo 11

      // Ciclo 12: PC=0x000C -> j Fin (Opcode: 0100_0000_0000_1100)
      // La UC ve Opcode=0x10. Debe saltar incondicionalmente a D (0x000C).
      #10;
      // Instrucción 'j': Salto incondicional. No escribe en banco, no usa ALU, actualiza PC.
      // s_inm=0: No relevante si no escribe.
      // we3=0: No escribe en el banco de registros.
      // Op=000: No relevante si no usa ALU.
      // s_inc=0: Elige la dirección de salto (instruccion[9:0]=0x00C) para el próximo valor del PC.
      // wez=0: No actualiza el flag z.
      s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; // Salta a Fin (0x000C) - Bucle infinito
      #10; // Finaliza ciclo 12

      // Opcional: Simular un par de ciclos más del bucle (como pide el PDF)
      // Ciclo 13
      #10;
      s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; // Salta a Fin (0x000C) - Bucle infinito
      #10; // Finaliza ciclo 13

      // Ciclo 14
      #10;
      s_inm = 1'b0; we3 = 1'b0; Op = 3'b000; s_inc = 1'b0; wez = 1'b0; // Salta a Fin (0x000C) - Bucle infinito
      #10; // Finaliza ciclo 14

      $finish; // Termina la simulación
    end

endmodule