module cut_function(
  input wire [15:0] offset,
  output wire [5:0] funct
);

  assign funct = offset[5:0];
  
endmodule