module mux_error(
    input wire       [1:0]       selector,
    output wire      [31:0]      out_data
);

    assign out_data = (selector == 2'b00) ? 32'b00000000000000000000000011111101 :
                      (selector == 2'b01) ? 32'b00000000000000000000000011111110 :
                      (selector == 2'b01) ? 32'b00000000000000000000000011111111 :
                      32'b0;
    
endmodule