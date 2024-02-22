module mux_aluB (
    input wire    [1:0]        selector,
    input wire    [31:0]       data_0,
    input wire    [31:0]       data_2,
    input wire    [31:0]       data_3,
    output wire   [31:0]       out_data
);

    assign out_data = (selector == 2'b00) ? data_0:
                      (selector == 2'b01) ? 32'b00000000000000000000000000000100 :
                      (selector == 2'b10) ? data_2:
                      (selector == 2'b11) ? data_3:
                      32'b0;



endmodule