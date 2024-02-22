module sign_xtend (
    input wire [15:0] Data_in,
    output wire [31:0] Data_out
);
    
    assign Data_out = (Data_in[15]) ? {{16{1'b1}}, Data_in} : {{16{1'b0}}, Data_in};

endmodule
