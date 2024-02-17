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
    reg [31:0] result_high; // result high
    reg [31:0] result_low; // result low
    reg [6:0]  cycle_counter; // Counter
    reg        zero_flag;
    // Multiplicação
    reg [31:0] A;
    reg [31:0] M_negative; // Complemento de 2 do M
    reg        q_minus_one; // q-1
    reg [64:0] mult_aux; // Auxiliar para multiplicação
    reg [31:0] M; // M
    reg [31:0] Q; // Q
    // Divisão
    reg [31:0] acumulator_div; // Acumulador para divisão 
    reg [63:0] div_aux; // Auxiliar para divisão
    reg [31:0] complemento_2_div; // Complemento de 2 do divisor
    reg [31:0] data_a_aux_div; // Auxiliar para data_a
    reg [31:0] data_b_aux_div; // Auxiliar para data_b
    reg inverter_quociente; // Inverter quociente
    reg [31:0] dividendo;
    reg [31:0] divisor;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            zero_flag <= 0;
            result_high <= 0;
            result_low <= 0;
            cycle_counter <= 0;
        end else begin
          if (cycle_counter < 33) begin
            if (set_md) begin // Divisão
              if (cycle_counter == 0) begin
                if (data_b == 0) begin
                    zero_flag = 1;
                end
                data_a_aux_div = data_a;
                data_b_aux_div = data_b;
                inverter_quociente = 0; // Inverter quociente
                if(data_a[31] == 1 && data_b[31] == 1) begin // Se ambos negativos
                  data_a_aux_div = ~data_a + 1;
                  data_b_aux_div = ~data_b + 1;
                end
                if(data_a[31] == 1 && data_b[31] == 0) begin // Se a negativo e b positivo
                  data_a_aux_div = ~data_a + 1;
                  inverter_quociente = 1; // Inverter quociente
                end
                if(data_a[31] == 0 && data_b[31] == 1) begin // Se a positivo e b negativo
                  data_b_aux_div = ~data_b + 1;
                  inverter_quociente = 1; // Inverter quociente
                end
                acumulator_div = 0; // acumulador
                dividendo = data_a_aux_div; // Dividendo Q
                divisor = data_b_aux_div; // Divisor M
                complemento_2_div = ~divisor + 1; // Complemento de 2 do divisor
              end else begin
                div_aux = {acumulator_div, dividendo};
                div_aux = div_aux << 1; // Shift left 1
                acumulator_div = div_aux[63:32];
                dividendo = div_aux[31:0];
                acumulator_div = acumulator_div + complemento_2_div; // Acumulador -= Divisor
                if (acumulator_div[31] == 1) begin
                // sim
                dividendo[0] = 0;
                acumulator_div = acumulator_div + divisor; // Acumulador += Divisor (reseta valor de A)
                end else begin
                // nao
                dividendo[0] = 1;
                end
                if (cycle_counter == 32) begin
                  if (inverter_quociente == 1) begin
                    result_low = ~dividendo + 1; // Inverter quociente
                    result_high = ~acumulator_div + 1; // resto = acumulator
                  end else begin
                    result_low = dividendo; // quociente = Q
                    result_high = acumulator_div; // resto = acumulator
                  end
                  
                end
              end
            end else begin // Multiplicação
              if (cycle_counter == 0) begin
                A = 0; // Acumulator
                q_minus_one = 0; // q-1
                M = data_a; // Multiplicando
                Q = data_b; // Q
                M_negative = ~M + 1; // Complemento de 2 do M
              end

              if (cycle_counter < 32) begin // Multiplicação só gasta 32 ciclos [0:31]
                if (Q[0] == q_minus_one) begin
                    A = A;
                    // Do nothing
                end else if (Q[0] == 0 && q_minus_one == 1) begin
                    A = A + M;
                end else if (Q[0] == 1 && q_minus_one == 0) begin
                    A = A + M_negative;
                end
                mult_aux = {A, Q, q_minus_one};
                mult_aux = $signed(mult_aux) >>> 1;
                A = mult_aux[64:33];
                Q = mult_aux[32:1];
                q_minus_one = mult_aux[0];
                result_high = A;
                result_low = Q;
                result_high = A;
                result_low = Q;
              end
            end
            cycle_counter <= cycle_counter + 1;
          end
        end
    end

    assign {out_high, out_low} = {result_high, result_low};
    assign zero = zero_flag;
    
endmodule
