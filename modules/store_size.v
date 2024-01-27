module store_size(
  input wire[1:0] ss_crtl,
  input wire[31:0] data_in,
  input wire[31:0] mem_data,
  output wire[31:0] data_out
);
  wire[31:0] mux_w1, mux_w2;

  assign mux_w1 = ss_crtl[0] ? {mem_data[31:16], data_in[15:0]} : data_in; // 01 e 00
  assign mux_w2 = ss_crtl[0] ? 32'b0 : {mem_data[31:8], data_in[7:0]};  // 11 e 10
  assign data_out = ss_crtl[1] ? mux_w2 : mux_w1;

endmodule