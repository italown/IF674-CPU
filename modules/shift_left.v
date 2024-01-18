module shift_left(
    input [31:0] data_in, 
    output [31:0] data_out
);

    assign data_out = data_in << 16;

endmodule
