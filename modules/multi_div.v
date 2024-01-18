module multi_div (
    input wire              clk,
    input wire              set_md,
    input wire              reset,
    input wire  [31:0]      data_a,
    input wire  [31:0]      data_b,
    output wire [31:0]      out_high,
    output wire [31:0]      out_low,
    output wire             zero
);
    reg [31:0] result_high;
    reg [31:0] result_low;
    reg        zero_flag;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            zero_flag <= 0;
            result_high <= 0;
            result_low <= 0;
        end else begin
            if (set_md) begin
                // Divisão
                if (data_b != 0) begin
                    result_high <= $signed(data_a) / $signed(data_b);
                    result_low <= $signed(data_a) % $signed(data_b); //TODO validar como salvar o ponto flutuante
                end
                // Se data_b for zero, mantenha os resultados anteriores
            end else begin
                // Multiplicação
                {result_high, result_low} <= data_a * data_b;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            zero_flag <= 0;
        else if (set_md && data_b == 0)
            zero_flag <= 1;
        else
            zero_flag <= 0;
    end

    assign {out_high, out_low} = {result_high, result_low};
    assign zero = zero_flag;
    
endmodule