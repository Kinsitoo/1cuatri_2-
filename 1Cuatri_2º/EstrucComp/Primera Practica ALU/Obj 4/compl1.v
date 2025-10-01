module compl1 (output wire [3:0] Out, input wire [3:0] Inp, input wire cp1);

  always @(cp1) begin
    
    if (cp1 == 2'b0)
      Out <= ~Inp;
    else if (cp1 != 2'b0)
      Out <= Inp;
      
  end

endmodule