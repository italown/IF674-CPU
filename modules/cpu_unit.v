module cpu_unit(
  input wire clk,
  input wire rst
);
  
  // Control wire
  wire [1:0] crtl_error;
  wire [1:0] crtl_iord;
  wire [1:0] crtl_insfht; 
  wire [1:0] crtl_ss;
  wire crtl_memwrite;
  wire crtl_irwrite;
  wire [2:0] crtl_regdst;
  wire [3:0] crtl_memtoreg;
  wire crtl_regwrite;
  wire crtl_ulasrca;
  wire crtl_ulasrcb;
  wire [2:0] crtl_pcsource;
  wire crtl_ls;
  wire [1:0] crtl_muxshf;

  // Control wire registers
  wire crtl_memDataRegWrite;
  wire crtl_rega;
  wire crtl_regb;
  wire crtl_regaluout;
  wire crtl_regepc;
  

  // Data wires
  wire PC_w;
  wire [31:0] MUX_PC_SOURCE_out;
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
  wire [31:0] READ_DATA_A_out;
  wire [31:0] READ_DATA_B_out;
  wire [31:0] MUX_ULA_A_out;
  wire [31:0] MUX_ULA_B_out;
  wire [31:0] XTEND_out;
  wire [31:0] SHIFT_LEFT_out;
  wire [31:0] SHIFT_LEFT_TWO_out;
  wire [31:0] EPC_out;
  wire [31:0] MUX_MUXSHFT_out;
  wire [31:0] MUX_INSFHT_out;

  // Data wires da ULA
  wire [2:0] ULA_CRTL_out; // Controle da ULA == ENTRADA DA ULA
  wire [31:0] ULA_RESULT; // Resultado da ULA
  wire ULA_OVERFLOW; // Sinaliza Overflow da ULA
  wire ULA_NEGATIVO; // Sinaliza negativo da ULA
  wire ULA_ZERO; // Sinaliza quando Resultado for Zero
  wire ULA_EQ; // Sinaliza se A=B
  wire ULA_GT; // Sinaliza se A>B
  wire ULA_LT; // Sinaliza se A<B



  Registrador PC_(clk, rst, PC_w, MUX_PC_SOURCE_out, PC_out);  // PC_w = ULA zero, MUX_PC_SOURCE_out = MUX_final

  mux_error MUX_ERROR_(crtl_error, MUX_error_out);  // crtl_error = unit_control_error, error_out = mux output

  mux_Iord_muxInSfht MUX_IORD_(crtl_iord, PC_out, MUX_error_out, ALU_out, MUX_iord_out);

  Memoria MEM_(MUX_iord_out, clk, crtl_memwrite, STORE_SIZE_out, MEM_out);

  store_size STORE_SIZE_(crtl_ss, REG_B_out, STORE_SIZE_out); 

  Instr_Reg IR_(clk, rst, crtl_irwrite, MEM_out, OPCODE, RS, RT, OFFSET);
 
  mux_regDst MUX_REG_DST_(crtl_regdst, RT, RS, OFFSET, MUX_REG_DST_out); 
              
  mux_memToReg MUX_MEM_TO_REG_(crtl_memtoreg, REG_B_out , ALU_out, REG_DES_out, REG_A_out, MEM_DATA_REG_out, XTEND_TO_32_out, HIGH_REG_out, LOW_REG_out , PC_out, LOAD_SIZE_out, MUX_MEM_TO_REG_out);

  Registrador MEM_DATA_REG_(clk, rst, crtl_memDataRegWrite,  MEM_out, MEM_DATA_REG_out);

  Banco_reg REG_BASE_(clk, rst, crtl_regwrite, RS, RT, MUX_REG_DST_out, MUX_MEM_TO_REG_out, READ_DATA_A_out, READ_DATA_B_out);
 
  Registrador REG_A_(clk, rst, crtl_rega, READ_DATA_A_out, REG_A_out);

  Registrador REG_B_(clk, rst, crtl_regb, READ_DATA_B_out, REG_B_out);

  mux_AluA MUX_ULA_A_(crtl_ulasrca, PC_out, REG_A_out, MUX_ULA_A_out);

  mux_aluB MUX_ULA_B_(crtl_ulasrcb, REG_B_out, XTEND_out, SHIFT_LEFT_out, MUX_ULA_B_out);

  sign_xtend XTEND_(OFFSET, XTEND_out);

  shift_left SHIFT_LEFT_(XTEND_out, SHIFT_LEFT_out);   

  Ula32 ULA_(MUX_ULA_A_out, MUX_ULA_B_out, ULA_CRTL_out, ULA_RESULT, ULA_OVERFLOW, ULA_NEGATIVO, ULA_ZERO, ULA_EQ, ULA_GT, ULA_LT);

  shift_left_two SHIFT_LEFT_TWO_(PC_out, RS, RT, OFFSET, SHIFT_LEFT_TWO_out);

  xtend_to_32 XTEND_TO_32_(ULA_LT, XTEND_TO_32 _out);

  Registrador REG_ALU_OUT_(clk, rst, crtl_regaluout, ULA_RESULT, ALU_out);

  Registrador REG_EPC_(clk, rst, crtl_regepc, ULA_RESULT, EPC_out);

  mux_pcSource MUX_PC_SOURCE_(crtl_pcsource, ULA_RESULT, EPC_out, ALU_out, REG_A_out, SHIFT_LEFT_TWO_out, LOAD_SIZE_out, MEM_DATA_REG_out, MUX_PC_SOURCE_out);

  load_size LOAD_SIZE_(crtl_ls, MEM_DATA_REG_out, LOAD_SIZE_out);

  mux_muxShft MUX_MUXSHFT_(crtl_muxshf, OFFSET, REG_B_out, MEM_DATA_REG_out, MUX_MUXSHFT_out);

  mux_Iord_muxInSfht MUX_INSFHT_(crtl_insfht, REG_A_out, XTEND_out, REG_B_out , MUX_INSFHT_out);

endmodule
