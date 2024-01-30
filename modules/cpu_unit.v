module cpu_unit(
  input wire clk,
  input wire rst
);
  
  // Control wire
  wire [1:0] crtl_error;
  wire [1:0] crtl_iord;
  wire [1:0] crtl_ss;
  wire crtl_mem_w;
  wire crtl_irwrite;
  wire [2:0] crtl_regdst;
  wire [3:0] crtl_memtoreg;

  // Data wires
  wire PC_w;
  wire [31:0] PC_in;
  wire [31:0] PC_out;
  wire [31:0] MUX_error_out;
  wire [31:0] MUX_iord_out;
  wire [31:0] ALU_out;
  wire [31:0] STORE_SIZE_out;
  wire [31:0] MEM_out;
  wire [31:0] REG_A_out;
  wire [31:0] REG_B_out;
  wire [5:0] OPCODE;          // Bits 31 a 26 da instrução
  wire [4:0] RS;              // Bits 25 a 21 da instrução
  wire [4:0] RT;              // Bits 20 a 16 da instrução
  wire [15:0] OFFSET;         // Bits 15 a 0 da instrução
  wire [31:0] MUX_REG_DST_out;
  wire [31:0] MUX_MEM_TO_REG_out;
  wire [31:0] REG_DES_out;
  wire [31:0] MEM_DATA_REG_out; 
  wire [31:0] XTEND_TO_32_out;
  wire [31:0] HIGH_REG_out;
  wire [31:0] LOW_REG_out;
  wire [31:0] LOAD_SIZE_out;

  Registrador PC_(clk, rst, PC_w, PC_in, PC_out);  // PC_w = ULA zero, PC_in = MUX_final

  mux_error MUX_ERROR_(crtl_error, MUX_error_out);  // crtl_error = unit_control_error, error_out = mux output

  mux_Iord_muxInSfht MUX_IORD_(crtl_iord, PC_out, MUX_error_out, ALU_out, MUX_iord_out);

  Memoria MEM_(MUX_iord_out, clk, crtl_mem_w, STORE_SIZE_out, MEM_out);

  store_size STORE_SIZE_(crtl_ss, REG_B_out, STORE_SIZE_out); 

  Instr_Reg IR_(clk, rst, crtl_irwrite, MEM_out, OPCODE, RS, RT, OFFSET);
 
  mux_regDst MUX_REG_DST_(crtl_regdst, RT, RS, OFFSET, MUX_REG_DST_out); 
              
  mux_memToReg MUX_MEM_TO_REG_(crtl_memtoreg, REG_B_out , ALU_out, REG_DES_out, REG_A_out, MEM_DATA_REG_out, XTEND_TO_32_out, HIGH_REG_out, LOW_REG_out , PC_out, LOAD_SIZE_out, MUX_MEM_TO_REG_out);

endmodule
