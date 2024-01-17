module mux_memToReg (
    input wire    [3:0]       selector,
    input wire    [31:0]      data_1,
    input wire    [31:0]      data_2,
    input wire    [31:0]      data_3,
    input wire    [31:0]      data_4,
    input wire    [31:0]      data_5,
    input wire    [31:0]      data_6,
    input wire    [31:0]      data_7,
    input wire    [31:0]      data_8,
    input wire    [31:0]      data_9,
    output wire   [31:0]      out_data
);

    assign out_data = (selector == 4'b0000) ? 32'b00000000000000000000000011100011 :
                      (selector == 4'b0001) ? data_1 :
                      (selector == 4'b0010) ? data_2 :
                      (selector == 4'b0011) ? data_3 :
                      (selector == 4'b0100) ? data_4 :
                      (selector == 4'b0101) ? data_5 :
                      (selector == 4'b0110) ? data_6 :
                      (selector == 4'b0111) ? data_7 :
                      (selector == 4'b1000) ? data_8 :
                      (selector == 4'b1001) ? data_9 :
                      32'b0;

    
endmodule