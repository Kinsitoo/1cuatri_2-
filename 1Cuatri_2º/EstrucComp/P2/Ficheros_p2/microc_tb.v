`timescale 1 ns / 10 ps
module microc_tb;

// Declaración de variables
reg clk, reset, s_inc, s_inm, we3, wez;
reg [2:0] Op;
wire z;
wire [5:0] Opcode;

// Instanciación del camino de datos
microc micro(Opcode, z, clk, reset, s_inc, s_inm, we3, wez, Op);

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

      // --- Inicio de la simulación ---
      reset = 1'b1; // Reset activo
      #5; // Espera un poco
      reset = 1'b0; // Fin del reset
      // PC ahora debería estar en 0x0000, listo para leer la primera instrucción del programa

      // --- Simulación del programa paso a paso ---
      // El testbench genera las señales de control para cada instrucción,
      // simulando el comportamiento de la Unidad de Control.

      // Ciclo 1: Instrucción en PC=0x0000: j Start (Opcode 010000)
      // La UC simulada sabe que está en PC=0x0000 y que la instrucción es un salto.
      // Debe generar señales para que el PC vaya a la dirección de destino (0x0005).
      s_inc = 1'b0; // s_inc=0 para que el PC tome la dirección de salto (D = 0x0005)
      s_inm = 1'b0; // No escribe inmediato
      we3 = 1'b0;   // No escribe en banco de regs
      Op = 3'b000;  // Irrelevante para saltos
      wez = 1'b0;   // Irrelevante para saltos
      $display("Ciclo 1: j Start. PC debería apuntar a 0x0005 al final del ciclo.");
      #20; // Finaliza ciclo 1

      // Ciclo 2: Instrucción en PC=0x0005: li#0 R2 (Opcode 000100)
      s_inc = 1'b1; // s_inc=1 para que PC vaya a PC+1 (0x0006)
      s_inm = 1'b1; // s_inm=1 para que el mux escriba la constante C
      we3 = 1'b1;   // we3=1 para escribir en el banco de registros
      Op = 3'b000;  // Irrelevante para li
      wez = 1'b0;   // Irrelevante para li
      $display("Ciclo 2: li#0 R2. R2 <- 0.");
      #20; // Finaliza ciclo 2

      // Ciclo 3: Instrucción en PC=0x0006: li#2 R1 (Opcode 000100)
      s_inc = 1'b1; // PC = PC+1 (0x0007)
      s_inm = 1'b1; // Escribir constante
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 3: li#2 R1. R1 <- 2.");
      #20; // Finaliza ciclo 3

      // Ciclo 4: Instrucción en PC=0x0007: li#4 R3 (Opcode 000100)
      s_inc = 1'b1; // PC = PC+1 (0x0008)
      s_inm = 1'b1; // Escribir constante
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 4: li#4 R3. R3 <- 4.");
      #20; // Finaliza ciclo 4

      // Ciclo 5: Instrucción en PC=0x0008: li#1 R4 (Opcode 000100)
      s_inc = 1'b1; // PC = PC+1 (0x0009)
      s_inm = 1'b1; // Escribir constante
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 5: li#1 R4. R4 <- 1.");
      #20; // Finaliza ciclo 5

      // Ciclo 6: Instrucción en PC=0x0009: add R2 R3 R2 (Opcode 101000)
      s_inc = 1'b1; // PC = PC+1 (0x000A)
      s_inm = 1'b0; // Escribir resultado de ALU
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b000;  // Op=000 -> ADD
      wez = 1'b1;   // Actualizar flag z
      $display("Ciclo 6: add R2 R3 R2. R2 <- R2(0) + R3(4) = 4. z <- (4==0?1:0)=0.");
      #20; // Finaliza ciclo 6

      // Ciclo 7: Instrucción en PC=0x000A: sub R1 R4 R1 (Opcode 101100)
      s_inc = 1'b1; // PC = PC+1 (0x000B)
      s_inm = 1'b0; // Escribir resultado de ALU
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b011;  // Op=011 -> SUB
      wez = 1'b1;   // Actualizar flag z
      $display("Ciclo 7: sub R1 R4 R1. R1 <- R1(2) - R4(1) = 1. z <- (1==0?1:0)=0.");
      #20; // Finaliza ciclo 7

      // Ciclo 8: Instrucción en PC=0x000B: jnz Iter (Opcode 010010)
      // En este ciclo, la UC simulada *debe* saber el estado actual de 'z'.
      // Suponemos que 'z' es 0 (resultado de la ALU del ciclo 7).
      // Si z=0, salta a Iter (0x0009), por lo tanto s_inc=0.
      s_inc = 1'b0; // s_inc=0 -> salta a Iter (0x0009)
      s_inm = 1'b0; // Irrelevante
      we3 = 1'b0;   // No escribe
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 8: jnz Iter. z=0, salta a 0x0009. PC <- 0x0009.");
      #20; // Finaliza ciclo 8, PC apunta a 0x0009

      // Ciclo 9: Instrucción en PC=0x0009: add R2 R3 R2 (Opcode 101000) - Segunda iteración
      s_inc = 1'b1; // PC = PC+1 (0x000A)
      s_inm = 1'b0; // Escribir resultado de ALU
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b000;  // Op=000 -> ADD
      wez = 1'b1;   // Actualizar flag z
      $display("Ciclo 9: add R2 R3 R2. R2 <- R2(4) + R3(4) = 8. z <- (8==0?1:0)=0.");
      #20; // Finaliza ciclo 9

      // Ciclo 10: Instrucción en PC=0x000A: sub R1 R4 R1 (Opcode 101100) - Segunda iteración
      s_inc = 1'b1; // PC = PC+1 (0x000B)
      s_inm = 1'b0; // Escribir resultado de ALU
      we3 = 1'b1;   // Escribir en banco
      Op = 3'b011;  // Op=011 -> SUB
      wez = 1'b1;   // Actualizar flag z
      $display("Ciclo 10: sub R1 R4 R1. R1 <- R1(1) - R4(1) = 0. z <- (0==0?1:0)=1.");
      #20; // Finaliza ciclo 10

      // Ciclo 11: Instrucción en PC=0x000B: jnz Iter (Opcode 010010)
      // En este ciclo, la UC simulada *debe* saber el estado actual de 'z'.
      // Suponemos que 'z' es 1 (resultado de la ALU del ciclo 10).
      // Si z=1, NO salta, PC = PC+1.
      s_inc = 1'b1; // s_inc=1 -> PC = PC+1 (0x000C)
      s_inm = 1'b0; // Irrelevante
      we3 = 1'b0;   // No escribe
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 11: jnz Iter. z=1, no salta. PC <- PC+1 = 0x000C.");
      #20; // Finaliza ciclo 11, PC apunta a 0x000C

      // Ciclo 12: Instrucción en PC=0x000C: j Fin (Opcode 010000) - Bucle infinito
      s_inc = 1'b0; // s_inc=0 -> salta a Fin (0x000C)
      s_inm = 1'b0; // Irrelevante
      we3 = 1'b0;   // No escribe
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 12: j Fin. Bucle infinito. PC <- 0x000C.");
      #20; // Finaliza ciclo 12, PC sigue en 0x000C

      // Ciclo 13: Instrucción en PC=0x000C: j Fin (Opcode 010000) - Bucle infinito continúa
      s_inc = 1'b0; // s_inc=0 -> salta a Fin (0x000C)
      s_inm = 1'b0; // Irrelevante
      we3 = 1'b0;   // No escribe
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 13: j Fin. Bucle infinito. PC <- 0x000C.");
      #20; // Finaliza ciclo 13, PC sigue en 0x000C

      // Ciclo 14: Instrucción en PC=0x000C: j Fin (Opcode 010000) - Bucle infinito continúa
      s_inc = 1'b0; // s_inc=0 -> salta a Fin (0x000C)
      s_inm = 1'b0; // Irrelevante
      we3 = 1'b0;   // No escribe
      Op = 3'b000;  // Irrelevante
      wez = 1'b0;   // Irrelevante
      $display("Ciclo 14: j Fin. Bucle infinito. PC <- 0x000C.");
      #20; // Finaliza ciclo 14, PC sigue en 0x000C

      $finish; // Termina la simulación
    end

endmodule