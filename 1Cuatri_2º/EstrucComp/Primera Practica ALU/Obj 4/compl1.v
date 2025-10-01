module compl1 (output wire [3:0] Out, input wire [3:0] Inp, input wire cp1);

  always @(cp1, Inp) begin
    
    if (cp1 == 1'b0)
      Out = ~Inp;
    else
      Out = Inp;
      
  end

endmodule