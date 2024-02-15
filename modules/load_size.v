module load_size(
  input wire[1:0] ls_crtl,
  input wire[31:0] data_in,
  output wire[31:0] data_out
);


  assign data_out = (ls_crtl == 2'b10) ? {24'b0, data_in[7:0]}               :
                    (ls_crtl == 2'b01) ? {16'b0, data_in[15:0]}              :
                    (ls_crtl == 2'b00) ? data_in                             :
                    32'b0;

endmodule
