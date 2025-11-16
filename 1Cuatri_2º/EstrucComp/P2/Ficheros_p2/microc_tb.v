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
  clk=0;
  #10;
  clk=1;
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

       // --- Simulación del programa de ejemplo ---
    // *** CICLO 1: PC=0x000 (j Start) -> Salto a 0x005 ***
    #10; 
    // Opcode 000100 (j). Control: s_inc=0 (Salto). No escribe nada.
    s_inc = 0; s_inm = 0; we3 = 0; wez = 0; Op = 3'b000; 

    // *** CICLO 2: PC=0x005 (li #0, R2) -> R2 = 0 ***
    #20; 
    // Opcode 0001 (li). Control: s_inc=1 (PC+1), s_inm=1 (Inm), we3=1 (Escribe R2).
    s_inc = 1; s_inm = 1; we3 = 1; wez = 0; Op = 3'b000; 

    // *** CICLO 3: PC=0x006 (li #2, R1) -> R1 = 2 ***
    #20;
    // Opcode 0001 (li). Control: s_inc=1, s_inm=1, we3=1 (Escribe R1).
    s_inc = 1; s_inm = 1; we3 = 1; wez = 0; Op = 3'b000; 
    
    // *** CICLO 4: PC=0x007 (li #4, R3) -> R3 = 4 ***
    #20;
    // Opcode 0001 (li). Control: s_inc=1, s_inm=1, we3=1 (Escribe R3).
    s_inc = 1; s_inm = 1; we3 = 1; wez = 0; Op = 3'b000;
    
    // *** CICLO 5: PC=0x008 (li #1, R4) -> R4 = 1 ***
    #20;
    // Opcode 0001 (li). Control: s_inc=1, s_inm=1, we3=1 (Escribe R4).
    s_inc = 1; s_inm = 1; we3 = 1; wez = 0; Op = 3'b000;

    // --- INICIO BUCHE (Iteración 1) ---

    // *** CICLO 6: PC=0x009 (add R2, R3, R2) -> R2 = 0 + 4 = 4. Z=0. ***
    #20;
    // Opcode 1010 (add). Control: s_inm=0 (ALU), we3=1, wez=1 (Actualiza Z). Op=3'b010 (ADD).
    s_inc = 1; s_inm = 0; we3 = 1; wez = 1; Op = 3'b010; 

    // *** CICLO 7: PC=0x00A (sub R1, R4, R1) -> R1 = 2 - 1 = 1. Z=0. ***
    #20;
    // Opcode 1011 (sub). Control: s_inm=0, we3=1, wez=1. Op=3'b011 (SUB).
    s_inc = 1; s_inm = 0; we3 = 1; wez = 1; Op = 3'b011; 

    // *** CICLO 8: PC=0x00B (jnz Iter) -> Z=0. Salta a 0x009. ***
    #20;
    // Opcode 001010 (jnz). Comprueba Z. Z=0 -> s_inc=0 (Salto). No escribe nada.
    s_inc = 0; s_inm = 0; we3 = 0; wez = 0; Op = 3'b000; 
    
    // --- BUCHE (Iteración 2) ---

    // *** CICLO 9: PC=0x009 (add R2, R3, R2) -> R2 = 4 + 4 = 8. Z=0. ***
    #20;
    s_inc = 1; s_inm = 0; we3 = 1; wez = 1; Op = 3'b010; 
    
    // *** CICLO 10: PC=0x00A (sub R1, R4, R1) -> R1 = 1 - 1 = 0. Z=1. ***
    #20;
    s_inc = 1; s_inm = 0; we3 = 1; wez = 1; Op = 3'b011;

    // *** CICLO 11: PC=0x00B (jnz Iter) -> Z=1. NO salta, PC+1 (0x00C). ***
    #20;
    // Z=1 -> s_inc=1 (PC+1).
    s_inc = 1; s_inm = 0; we3 = 0; wez = 0; Op = 3'b000;

    // --- FIN BUCHE (Bucle Infinito) ---

    // *** CICLO 12: PC=0x00C (j Fin) -> Salta a 0x00C (bucle infinito). ***
    #20;
    // Opcode 000100 (j) -> s_inc=0.
    s_inc = 0; s_inm = 0; we3 = 0; wez = 0; Op = 3'b000;

    // *** CICLO 13: PC=0x00C (j Fin) -> Se mantiene el bucle. ***
    #20;
    s_inc = 0; s_inm = 0; we3 = 0; wez = 0; Op = 3'b000;
    
    // Terminamos la simulación
    #20;
  $finish;
end

endmodule