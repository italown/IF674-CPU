module mux_Iord_error_muxInSfht (
    input wire   [1:0]     selector,
    input wire   [31:0]    data_0,
    input wire   [31:0]    data_1,
    input wire   [31:0]    data_2,
    output wire  [31:0]    out_data
);
    
    assign out_data = (selector == 2'b00) ? data_0 :
    assign out_data = (selector == 2'b01) ? data_0 :
    assign out_data = (selector == 2'b1x) ? data_0 :
    32'b0;

endmodule