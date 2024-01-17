module mux_pcSource (
    input wire      [2:0]       selector,
    input wire      [31:0]      data_0,
    input wire      [31:0]      data_1,
    input wire      [31:0]      data_2,
    input wire      [31:0]      data_3,
    input wire      [31:0]      data_4,
    input wire      [31:0]      data_5,
    input wire      [31:0]      data_6,
    input wire      [31:0]      data_7,
    output wire     [31:0]      out_data
);

    assign out_data = (selector == 3'b000) ? data_0 :
                      (selector == 3'b001) ? data_1 :
                      (selector == 3'b010) ? data_2 :
                      (selector == 3'b011) ? data_3 :
                      (selector == 3'b100) ? data_4 :
                      (selector == 3'b101) ? data_5 :
                      (selector == 3'b110) ? data_6 :
                      data_7;
    
endmodule