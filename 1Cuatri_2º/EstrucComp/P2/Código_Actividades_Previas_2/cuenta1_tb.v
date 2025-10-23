`timescale 1ps/10ps
module cuenta1_tb;

  reg [2:0] valor_t;
  reg start_t, clk_t;
  wire [3:0] cuenta_t;
  wire fin;

  cuenta1 cuenta(valor_t, start_t, clk_t, cuenta_t, fin);

    always @(posedge clk_t) 
      if (clk_t)
        
      


  initial begin



  end
  $finish
  
endmodule