module mux_regDst (
    input wire   [2:0]      selector,
    input wire   [4:0]      data_0,
    input wire   [4:0]      data_1,
    input wire   [4:0]      data_3,
    output wire  [4:0]      out_data
);
    
    assign out_data = (selector == 3'b000) ? data_0   :
                      (selector == 3'b001) ? data_1   :
                      (selector == 3'b010) ? 5'b11101 :
                      (selector == 3'b011) ? data_3   :
                      (selector == 3'b100) ? 5'b11111 :
                      5'b00000;

endmodule