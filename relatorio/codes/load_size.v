module load_size(
  input wire[1:0] ls_crtl,
  input wire[31:0] data_in,
  output wire[31:0] data_out
);
  wire[31:0] mux_w1, mux_w2;

  assign mux_w1 = ls_crtl[0] ? {16'b0, data_in[15:0]} : data_in; // 01 e 00
  assign mux_w2 = ls_crtl[0] ? 32'b0 : {24'b0, data_in[7:0]};  // 11 e 10
  assign data_out = ls_crtl[1] ? mux_w2 : mux_w1;

endmodule
