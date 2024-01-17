module mux_AluA (
    input wire                 selector,
    input wire     [31:0]      data_0,
    input wire     [31:0]      data_1,
    output wire    [31:0]      out_data
);

assign out_data = (selector) ? data_0 : data_1;
    
endmodule