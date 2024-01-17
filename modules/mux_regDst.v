module mux_regDst (
    input wire   [2:0]       selector,
    input wire   [31:0]      data_0,
    input wire   [31:0]      data_1,
    input wire   [31:0]      data_3,
    output wire  [31:0]      out_data
);
    
    assign out_data = (selector == 3'b000) ? data_0                               :
                      (selector == 3'b001) ? data_1                               :
                      (selector == 3'b010) ? 32'b00000000000000000000000000011101 :
                      (selector == 3'b011) ? data_3                               :
                      (selector == 3'b1xx) ? 32'b00000000000000000000000000011111 :
                      32'b0;

endmodule