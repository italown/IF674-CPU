module shift_left_two(
  input wire [31:0] PC_in,
  input wire [4:0] RS,        // Bits 25 a 21 da instrução
  input wire [4:0] RT,        // Bits 20 a 16 da instrução
  input wire [15:0] OFFSET,  // Bits 15 a 0 da instrução
  output wire [31:0] data_out
);

  wire [27:0] temp;

  assign temp = {2'b0, RS, RT, OFFSET} << 2;
  assign data_out = {PC_in[31:28], temp};

endmodule
