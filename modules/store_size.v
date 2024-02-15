module store_size(
  input wire[1:0] ss_crtl,
  input wire[31:0] data_in,
  // input wire[31:0] mem_data,
  output wire[31:0] data_out
);
  wire[31:0] mux_w1, mux_w2;

  // foi percebido que não precisavamos do mem_data e implementamos igual o load_size
  // O codigo antigo foi comentado caso precisarmos dele no futuro
  
  // assign mux_w1 = ss_crtl[0] ? {mem_data[31:16], data_in[15:0]} : data_in; // 01 e 00
  // assign mux_w2 = ss_crtl[0] ? 32'b0 : {mem_data[31:8], data_in[7:0]};  // 11 e 10
  // assign data_out = ss_crtl[1] ? mux_w2 : mux_w1;

  assign data_out = (ss_crtl == 2'b10) ? {24'b0, data_in[7:0]}               :
                    (ss_crtl == 2'b01) ? {16'b0, data_in[15:0]}              :
                    (ss_crtl == 2'b00) ? data_in                             :
                    32'b0;

endmodule