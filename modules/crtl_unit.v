module crtl_unit(
  input wire clk,
  input wire reset,

  input wire [5:0] FUNCT,
  input wire [5:0] OPCODE,
  input wire eq,
  input wire gt,

  // Control wire
  output reg [1:0] crtl_error,
  output reg [1:0] crtl_iord,
  output reg [1:0] crtl_insfht, 
  output reg [1:0] crtl_ss,
  output reg crtl_memwrite,
  output reg crtl_irwrite,
  output reg [2:0] crtl_regdst,
  output reg [3:0] crtl_memtoreg,
  output reg crtl_regwrite,
  output reg crtl_ulasrca,
  output reg [1:0] crtl_ulasrcb,
  output reg [2:0] crtl_pcsource,
  output reg [1:0] crtl_ls,
  output reg [1:0] crtl_muxshf,
  output reg [2:0] crtl_aluop,
  output reg crtl_setmd,
  output reg crtl_pcwritecond,
  output reg crtl_pcwrite,
  // Control wire reg desloc
  output reg [2:0] crtl_sideshifter,
  // Control wire registers
  output reg crtl_memDataRegWrite,
  output reg crtl_rega,
  output reg crtl_regb,
  output reg crtl_regaluout,
  output reg crtl_regepc,
  output reg crtl_reghigh,
  output reg crtl_reglow,
  output reg out_reset
);

reg [5:0] STATE; // Um estado para cada instrução
reg [5:0] COUNTER = 0; // Instrução pode gastar até 32 ciclos
reg STARTER = 0;
// Parametros
  // Main state
  parameter ST_COMMON = 6'b000000;
  parameter ST_ADDI = 6'b000001;
  parameter ST_ADDIU = 6'b000010;
  parameter ST_BEQ = 6'b000011;
  parameter ST_BNE = 6'b000100;
  parameter ST_BLE = 6'b000101;
  parameter ST_BGT = 6'b000110;
  parameter ST_SRAM = 6'b000111;
  parameter ST_LB = 6'b001000;
  parameter ST_LH = 6'b001001;
  parameter ST_LUI = 6'b001010;
  parameter ST_LW = 6'b001011;
  parameter ST_SB = 6'b001100;
  parameter ST_SH = 6'b001101;
  parameter ST_SLTI = 6'b001110;
  parameter ST_SW = 6'b001111;
  parameter ST_J = 6'b010000;
  parameter ST_JAL = 6'b010001; //
  parameter ST_ADD = 6'b010010;
  parameter ST_AND = 6'b010011;
  parameter ST_DIV = 6'b010100;
  parameter ST_MULT = 6'b010101;
  parameter ST_JR = 6'b010110;
  parameter ST_MFHI = 6'b010111;
  parameter ST_MFLO = 6'b011000;
  parameter ST_SLL = 6'b011001;
  parameter ST_SLLV = 6'b011010;
  parameter ST_SLT = 6'b011011;
  parameter ST_SRA = 6'b011100;
  parameter ST_SRAV = 6'b011101;
  parameter ST_SRL = 6'b011110;
  parameter ST_SUB = 6'b011111;
  parameter ST_BREAK = 6'b100000;
  parameter ST_RTE = 6'b100001;
  parameter ST_XCHG = 6'b100010;
  parameter ST_RESET = 6'b100011;
  // Opcode state
  // TIPO I
  parameter TIPO_R = 6'b000000;
  parameter ADDI = 6'b001000;
  parameter ADDIU = 6'b001001;
  parameter BEQ = 6'b000100;
  parameter BNE = 6'b000101;
  parameter BLE = 6'b000110;
  parameter BGT = 6'b000111;
  parameter SRAM = 6'b000001;
  parameter LB = 6'b100000;
  parameter LH = 6'b100001;
  parameter LUI = 6'b001111;
  parameter LW = 6'b100011;
  parameter SB = 6'b101000;
  parameter SH = 6'b101001;
  parameter SLTI = 6'b001010;
  parameter SW = 6'b101011;
  // TIPO J
  parameter J = 6'b000010;
  parameter JAL = 6'b000011;
  // Funct state
  parameter ADD = 6'b100000;
  parameter AND = 6'b100100;
  parameter DIV = 6'b011010;
  parameter MULT = 6'b011000;
  parameter JR = 6'b001000;
  parameter MFHI = 6'b010000;
  parameter MFLO = 6'b010010;
  parameter SLL = 6'b000000;
  parameter SLLV = 6'b000100;
  parameter SLT = 6'b101010;
  parameter SRA = 6'b000011;
  parameter SRAV = 6'b000111;
  parameter SRL = 6'b000010;
  parameter SUB = 6'b100010;
  parameter BREAK = 6'b001101;
  parameter RTE = 6'b010011;
  parameter XCHG = 6'b000101;

always @(posedge clk) begin

  if (STARTER == 0) begin
    if (COUNTER == 0) begin
      COUNTER = COUNTER + 1;
    end else if (COUNTER == 1) begin
      STARTER = 1;
      out_reset = 1'b1;
      COUNTER = 0;
    end
  end

  if (reset == 1'b1 || out_reset == 1'b1) begin
      if (STATE !== ST_RESET) begin
        STATE = ST_RESET;
        // Setting all signals
        crtl_ulasrca = 1'b0;      
        crtl_ulasrcb = 2'b00;         
        crtl_aluop = 3'b000;                     
        crtl_pcsource = 3'b000;     
        crtl_iord = 2'b00;          
        crtl_memwrite = 1'b0;       
        crtl_error = 2'b00;
        crtl_insfht = 2'b00;
        crtl_ss = 2'b00;
        crtl_irwrite = 1'b0;        
        crtl_regdst = 3'b000;         
        crtl_memtoreg = 4'b0000;      
        crtl_regwrite = 1'b0;           
        crtl_ls = 2'b00;
        crtl_muxshf = 2'b00;
        crtl_setmd = 1'b0;
        crtl_pcwritecond = 1'b0;
        crtl_pcwrite = 1'b0;        
        crtl_sideshifter = 3'b000;
        crtl_memDataRegWrite = 1'b0;
        crtl_rega = 1'b0;             
        crtl_regb = 1'b0;             
        crtl_regaluout = 1'b0;        
        crtl_regepc = 1'b0;
        crtl_reghigh = 1'b0;
        crtl_reglow = 1'b0;
        out_reset = 1'b1;

        COUNTER = 0;
      end
      else begin
        STATE = ST_COMMON;
        // Setting all signals
        crtl_ulasrca = 1'b0;          
        crtl_ulasrcb = 2'b00;         
        crtl_aluop = 3'b000;                     
        crtl_pcsource = 3'b000;     
        crtl_iord = 2'b00;          
        crtl_memwrite = 1'b0;       
        crtl_error = 2'b00;
        crtl_insfht = 2'b00;
        crtl_ss = 2'b00;
        crtl_irwrite = 1'b0;        
        crtl_regdst = 3'b000;         
        crtl_memtoreg = 4'b0000;      
        crtl_regwrite = 1'b0;           
        crtl_ls = 2'b00;
        crtl_muxshf = 2'b00;
        crtl_setmd = 1'b0;
        crtl_pcwritecond = 1'b0;
        crtl_pcwrite = 1'b0;        
        crtl_sideshifter = 3'b000;
        crtl_memDataRegWrite = 1'b0;
        crtl_rega = 1'b0;             
        crtl_regb = 1'b0;             
        crtl_regaluout = 1'b0;        
        crtl_regepc = 1'b0;
        crtl_reghigh = 1'b0;
        crtl_reglow = 1'b0;
        out_reset = 1'b0;

        COUNTER = 0;
      end
  end
  else begin
    case (STATE)
      ST_COMMON: begin
        if (COUNTER == 6'b000000 || COUNTER == 6'b000001 ) begin
          STATE = ST_COMMON;
          // Setting all signals
          crtl_ulasrca = 1'b0;        ///////
          crtl_ulasrcb = 2'b01;       ///////
          crtl_aluop = 3'b001;        ///////
          crtl_pcsource = 3'b000;     ///////
          crtl_iord = 2'b00;          ///////
          crtl_memwrite = 1'b0;       ///////
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b1;
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          // Setting counter for next operation
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;
          // Setting all signals
          crtl_ulasrca = 1'b0;        ///////
          crtl_ulasrcb = 2'b01;       ///////
          crtl_aluop = 3'b001;        ///////
          crtl_pcsource = 3'b000;     ///////
          crtl_iord = 2'b00;          ///////
          crtl_memwrite = 1'b0;       ///////
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b1;        ///////
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;        ///////
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          // Setting counter for next operation
          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 6'b000011) begin
          case (OPCODE)
            ADDI: begin
              STATE = ST_ADDI;
            end
            ADDIU: begin
              STATE = ST_ADDIU;
            end
            BEQ: begin
              STATE = ST_BEQ;
            end
            BNE: begin
              STATE = ST_BNE;
            end
            BLE: begin
              STATE = ST_BLE;
            end
            BGT: begin
              STATE = ST_BGT;
            end
            SRAM: begin
              STATE = ST_SRAM;
            end
            LB: begin
              STATE = ST_LB;
            end
            LH: begin
              STATE = ST_LH;
            end
            LUI: begin
              STATE = ST_LUI;
            end
            LW: begin
              STATE = ST_LW;
            end
            SB: begin
              STATE = ST_SB;
            end
            SH: begin
              STATE = ST_SH;
            end
            SLTI: begin
              STATE = ST_SLTI;
            end
            SW: begin
              STATE = ST_SW;
            end
            J: begin
              STATE = ST_J;
            end
            JAL: begin
              STATE = ST_JAL;
            end
            TIPO_R: begin
              case(FUNCT)
              ADD: begin
                STATE = ST_ADD;
              end
              AND: begin
                STATE = ST_AND;
              end
              DIV: begin
                STATE = ST_DIV;
              end
              MULT: begin
                STATE = ST_MULT;
              end
              JR: begin
                STATE = ST_JR;
              end
              MFHI: begin
                STATE = ST_MFHI;
              end
              MFLO: begin
                STATE = ST_MFLO;
              end
              SLL: begin
                STATE = ST_SLL;
              end
              SLLV: begin
                STATE = ST_SLLV;
              end
              SLT: begin
                STATE = ST_SLT;
              end
              SRA: begin
                STATE = ST_SRA;
              end
              SRAV: begin
                STATE = ST_SRAV;
              end
              SRL: begin
                STATE = ST_SRL;
              end
              SUB: begin
                STATE = ST_SUB;
              end
              BREAK: begin
                STATE = ST_BREAK;
              end
              RTE: begin
                STATE = ST_RTE;
              end
              XCHG: begin
                STATE = ST_XCHG;
              end
              endcase
            end
          endcase
          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        ///////
          crtl_aluop = 3'b000;         ///////
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        ///////
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        ///////
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          // Setting counter for next operation
          COUNTER = 6'b000000;
        end
      end
      ST_ADD: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_ADD;
          // Setting all signals
          crtl_ulasrca = 1'b0;            
          crtl_ulasrcb = 2'b00;            
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;         ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;             ///////
          crtl_regb = 1'b1;             ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 6'b000001) begin
          STATE = ST_ADD;
          // Setting all signals
          crtl_ulasrca = 1'b1;         /////// 
          crtl_ulasrcb = 2'b00;         ///////
          crtl_aluop = 3'b001;           ///////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b1;         ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             ///////
          crtl_regb = 1'b0;             ///////
          crtl_regaluout = 1'b1;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end
        else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;
          // Setting all signals
          crtl_ulasrca = 1'b1;          
          crtl_ulasrcb = 2'b00;         
          crtl_aluop =3'b001;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b011;         ///////
          crtl_memtoreg = 4'b0010;      ///////
          crtl_regwrite = 1'b1;         ///////  
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          
          COUNTER = 0;
        end
      end
      ST_RTE: begin
        if (COUNTER == 6'b000000) begin //TODO Validar
          STATE = ST_COMMON;
          crtl_ulasrca = 1'b0;          
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b001;        ////////  
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;           
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;            ////////        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_SUB: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_SUB;

          crtl_ulasrca = 1'b0;          
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;              ////////       
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                   ///////        
          crtl_regb = 1'b1;                   ///////
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_SUB;

          crtl_ulasrca = 1'b1;            ///////       
          crtl_ulasrcb = 2'b00;           //////       
          crtl_aluop = 3'b010;            //////             
          crtl_pcsource = 3'b000;         
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;           
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               ///////
          crtl_regb = 1'b0;               /////// 
          crtl_regaluout = 1'b1;          ///////       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;
          
          crtl_ulasrca = 1'b1;          
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b011;         ///////
          crtl_memtoreg = 4'b0010;      ///////
          crtl_regwrite = 1'b1;         ///////  
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_AND: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_AND;

          crtl_ulasrca = 1'b0;          
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;              ////////       
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                   ///////        
          crtl_regb = 1'b1;                   ///////
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_AND;

          crtl_ulasrca = 1'b1;            ///////       
          crtl_ulasrcb = 2'b00;           //////       
          crtl_aluop = 3'b011;            //////             
          crtl_pcsource = 3'b000;         
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;           
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               ///////
          crtl_regb = 1'b0;               /////// 
          crtl_regaluout = 1'b1;          ///////       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;
          
          crtl_ulasrca = 1'b1;          
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b011;         ///////
          crtl_memtoreg = 4'b0010;      ///////
          crtl_regwrite = 1'b1;         ///////  
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_XCHG: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_XCHG;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;      
          crtl_aluop = 3'b000;         
          crtl_pcsource = 3'b000;    
          crtl_iord = 2'b00;         
          crtl_memwrite = 1'b0;      
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;       
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;       
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                  ///////
          crtl_regb = 1'b1;                  //////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_XCHG;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;               ////////
          crtl_memtoreg = 4'b0100;            ////////
          crtl_regwrite = 1'b1;               ////////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                   ////////
          crtl_regb = 1'b0;                   /////////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;
          
          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b001;             ////////
          crtl_memtoreg = 4'b0001;          ////////
          crtl_regwrite = 1'b1;             ////////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_BREAK: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_COMMON;
          crtl_ulasrca = 1'b0;              //////
          crtl_ulasrcb = 2'b01;             //////
          crtl_aluop = 3'b010;              //////          
          crtl_pcsource = 3'b000;           ////// 
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;                //////
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_JR: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_JR;

          crtl_ulasrca = 1'b0;      
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;    ///////       
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;        ///////
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;       
        end
        else if(COUNTER == 6'b000001) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;      
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b011;  ///////   
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;        
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;     ///////   
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;        ///////
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;      
        end
      end
      ST_MFHI: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_COMMON;
          crtl_ulasrca = 1'b0;      
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b011;         /////  
          crtl_memtoreg = 4'b1000;      /////
          crtl_regwrite = 1'b1;         /////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_MFLO: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_COMMON;
          crtl_ulasrca = 1'b0;      
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b011;          /////
          crtl_memtoreg = 4'b1001;       /////
          crtl_regwrite = 1'b1;          /////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          COUNTER = 0;
        end
      end
      ST_MULT: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_MULT;
          
          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;           ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;               ///////
          crtl_regb = 1'b1;               //////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER < 6'b100000) begin
          STATE = ST_MULT;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b1;              ///////
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                //////
          crtl_regb = 1'b0;                //////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b100000) begin
          STATE = ST_COMMON;
          
          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;             
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b1;            ///////
          crtl_reglow = 1'b1;             //////

          COUNTER = 0;
        end
      end
      ST_DIV: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_DIV;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 ////////
          crtl_regb = 1'b1;                 ////////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER < 6'b100000) begin
          STATE = ST_DIV;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;            ////////
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             ///////
          crtl_regb = 1'b0;             ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b100000) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b1;            ///////
          crtl_reglow = 1'b1;             ///////

          COUNTER = 0;
        end
      end
      ST_SLT:begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_SLT;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 ///////
          crtl_regb = 1'b1;                 ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b1;          /////////        
          crtl_ulasrcb = 2'b00;         ////////        
          crtl_aluop = 3'b111;          ///////    
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b011;         /////////
          crtl_memtoreg = 4'b0110;      ////////
          crtl_regwrite = 1'b1;         ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             ///////
          crtl_regb = 1'b0;             ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end 
      ST_LB:begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_LB;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;          ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;             ///////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_LB;

          crtl_ulasrca = 1'b1;          //////      
          crtl_ulasrcb = 2'b10;         //////
          crtl_aluop = 3'b001;          //////
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               ////////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b1;          ////////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010 || COUNTER == 6'b000011) begin
          STATE = ST_LB;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;          /////////
          crtl_memwrite = 1'b0;       ////////    
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000100) begin
          STATE = ST_LB;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b1;      ////////
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000101) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;               ///////
          crtl_memtoreg = 4'b1010;
          crtl_regwrite = 1'b1;               ////////
          crtl_ls = 2'b10;                    ///////
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;        ///////
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_SRAM: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_SRAM;

          crtl_ulasrca = 1'b0;      
          crtl_ulasrcb = 2'b00;         
          crtl_aluop = 3'b000;                     
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;   //////        
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;       //////
          crtl_regb = 1'b1;       //////
          crtl_regaluout = 1'b0;        
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
        end
        else if (COUNTER == 6'b000001) begin
          STATE = ST_SRAM;

          crtl_ulasrca = 1'b1;      //////
          crtl_ulasrcb = 2'b10;     ////// TODO validar   
          crtl_aluop = 3'b001;      //////               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;         
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;       //////
          crtl_regb = 1'b0;       //////
          crtl_regaluout = 1'b1;  //////      
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
        end
        else if(COUNTER == 6'b000010) begin
          STATE = ST_SRAM;
          
          crtl_ulasrca = 1'b1;     
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;      //////    
          crtl_memwrite = 1'b0;   //////    
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;         
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;       
          crtl_regb = 1'b0;       
          crtl_regaluout = 1'b0;       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
          
        end
        else if(COUNTER == 6'b000011) begin
          STATE = ST_SRAM;
          
          crtl_ulasrca = 1'b1;     
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;      //////    
          crtl_memwrite = 1'b0;   //////    
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;         
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;       
          crtl_regb = 1'b0;       
          crtl_regaluout = 1'b0;       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
        end
        else if(COUNTER == 6'b000100) begin
          STATE = ST_SRAM;
          
          crtl_ulasrca = 1'b1;     
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;         
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;         
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b1;   /////
          crtl_rega = 1'b0;       
          crtl_regb = 1'b0;       
          crtl_regaluout = 1'b0;       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
          
        end
        else if(COUNTER == 6'b000101) begin
          STATE = ST_SRAM;
          
          crtl_ulasrca = 1'b1;     
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;         
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b10;   //////
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;         
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b001; /////
          crtl_memDataRegWrite = 1'b0;  
          crtl_rega = 1'b0;       
          crtl_regb = 1'b0;       
          crtl_regaluout = 1'b0;       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
          
        end
          else if(COUNTER == 6'b000110) begin
          STATE = ST_SRAM;
          
          crtl_ulasrca = 1'b1;     
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;         
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b10;   //////
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;         
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b11;   /////
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b100; /////
          crtl_memDataRegWrite = 1'b0;  
          crtl_rega = 1'b0;       
          crtl_regb = 1'b0;       
          crtl_regaluout = 1'b0;       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
          
        end
          else if(COUNTER == 6'b000111) begin
          STATE = ST_COMMON;
          
          crtl_ulasrca = 1'b1;     
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;         
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b10;   
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;    /////     
          crtl_memtoreg = 4'b0011; /////     
          crtl_regwrite = 1'b1;    /////       
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b11;   
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b100; 
          crtl_memDataRegWrite = 1'b0;  
          crtl_rega = 1'b0;       
          crtl_regb = 1'b0;       
          crtl_regaluout = 1'b0;       
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
          
        end
      end
      ST_BEQ: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_BEQ;

          crtl_ulasrca = 1'b0;      /////
          crtl_ulasrcb = 2'b11;     /////    
          crtl_aluop = 3'b001;      /////               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;     /////      
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;        /////     
          crtl_regb = 1'b1;        /////     
          crtl_regaluout = 1'b1;   /////     
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
        end
        else if(COUNTER == 6'b000001) begin
          
          STATE = ST_BEQ;

          crtl_ulasrca = 1'b1;      /////
          crtl_ulasrcb = 2'b00;     /////    
          crtl_aluop = 3'b111;      /////               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;          
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;        /////     
          crtl_regb = 1'b0;        /////     
          crtl_regaluout = 1'b0;   /////     
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER+1;
        end
        else if(COUNTER == 6'b000010 && eq == 0) begin
          
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b1;      /////
          crtl_ulasrcb = 2'b00;     /////    
          crtl_aluop = 3'b111;      /////               
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;          
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;        /////     
          crtl_regb = 1'b0;        /////     
          crtl_regaluout = 1'b0;   /////     
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
        else if(COUNTER == 6'b000010 && eq == 1) begin

          STATE = ST_COMMON;

          crtl_ulasrca = 1'b1;      
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b111;         
          crtl_pcsource = 3'b010;     /////
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         
          crtl_memtoreg = 4'b0000;      
          crtl_regwrite = 1'b0;          
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;       /////    
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;            
          crtl_regb = 1'b0;            
          crtl_regaluout = 1'b0;    
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_ADDI: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_ADDI;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;           //////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;               //////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_ADDI;

          crtl_ulasrca = 1'b1;        
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;           
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                //////               
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b1;           /////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_ADDI;

          crtl_ulasrca = 1'b1;        
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         //////
          crtl_memtoreg = 4'b0010;      /////
          crtl_regwrite = 1'b1;         ////// 
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;     
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;           /////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000011) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b1;        
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         //////
          crtl_memtoreg = 4'b0010;      /////
          crtl_regwrite = 1'b1;         ////// 
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;     
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;           /////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_BNE: begin
        if(COUNTER == 6'b000000) begin
          STATE = ST_BNE;

          crtl_ulasrca = 1'b0;              //////        
          crtl_ulasrcb = 2'b11;             //////
          crtl_aluop = 3'b001;              //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             //////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;               //////
          crtl_regb = 1'b1;               ////// 
          crtl_regaluout = 1'b1;          //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_BNE;

          crtl_ulasrca = 1'b1;              //////
          crtl_ulasrcb = 2'b00;             //////
          crtl_aluop = 3'b111;              //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               //////
          crtl_regb = 1'b0;               //////
          crtl_regaluout = 1'b0;          //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010 && eq == 0) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b010;           ///////     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;                ///////        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end else if (COUNTER == 6'b000010 && eq == 1) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_BLE: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_BLE;

          crtl_ulasrca = 1'b0;              //////
          crtl_ulasrcb = 2'b11;             //////        
          crtl_aluop = 3'b001;              //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ///////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 //////
          crtl_regb = 1'b1;                 //////
          crtl_regaluout = 1'b1;            //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          
          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_BLE;

          crtl_ulasrca = 1'b1;            //////        
          crtl_ulasrcb = 2'b00;           //////
          crtl_aluop = 3'b111;            //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             ////////  
          crtl_regb = 1'b0;             ///////
          crtl_regaluout = 1'b0;        //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010 && (gt == 0)) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b010;           ////////
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;              ////////        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end else if (COUNTER == 6'b000010 && gt == 1) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_BGT: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_BGT;

          crtl_ulasrca = 1'b0;              //////
          crtl_ulasrcb = 2'b11;             //////        
          crtl_aluop = 3'b001;              //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ///////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 //////
          crtl_regb = 1'b1;                 //////
          crtl_regaluout = 1'b1;            //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          
          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_BGT;

          crtl_ulasrca = 1'b1;            //////        
          crtl_ulasrcb = 2'b00;           //////
          crtl_aluop = 3'b111;            //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;             ////////  
          crtl_regb = 1'b0;             ///////
          crtl_regaluout = 1'b0;        //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010 && gt == 1) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b010;           ////////
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;              ////////        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end else if (COUNTER == 6'b000010 && gt == 0) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_ADDIU: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_ADDIU;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;           //////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;               //////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_ADDIU;

          crtl_ulasrca = 1'b1;            /////
          crtl_ulasrcb = 2'b10;           /////      
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;           
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                //////               
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b1;           /////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b1;        
          crtl_ulasrcb = 2'b10;        
          crtl_aluop = 3'b000;                    
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;         //////
          crtl_memtoreg = 4'b0010;      /////
          crtl_regwrite = 1'b1;         ////// 
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;     
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;           /////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_LH:begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_LH;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;          ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;             ///////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_LH;

          crtl_ulasrca = 1'b1;          //////      
          crtl_ulasrcb = 2'b10;         //////
          crtl_aluop = 3'b001;          //////
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               ////////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b1;          ////////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010 || COUNTER == 6'b000011) begin
          STATE = ST_LH;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;          /////////
          crtl_memwrite = 1'b0;       ////////    
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000100) begin
          STATE = ST_LH;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b1;      ////////
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000101) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;               ///////
          crtl_memtoreg = 4'b1010;
          crtl_regwrite = 1'b1;               ////////
          crtl_ls = 2'b01;                    ///////
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;        ///////
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_LW:begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_LW;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;          ///////
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;             ///////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_LW;

          crtl_ulasrca = 1'b1;          //////      
          crtl_ulasrcb = 2'b10;         //////
          crtl_aluop = 3'b001;          //////
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               ////////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b1;          ////////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010 || COUNTER == 6'b000011) begin
          STATE = ST_LW;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;          /////////
          crtl_memwrite = 1'b0;       ////////    
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000100) begin
          STATE = ST_LW;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 2'b00;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b1;      ////////
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000101) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;               ///////
          crtl_memtoreg = 4'b1010;
          crtl_regwrite = 1'b1;               ////////
          crtl_ls = 2'b00;                    ///////
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;        ///////
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_LUI: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_LUI;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b01;            ///////
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b01;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b001;      ///////
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_LUI;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b01;        //////
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b01;        //////
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b010;   //////
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;           //////
          crtl_memtoreg = 4'b0011;        //////
          crtl_regwrite = 1'b1;           //////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;      //////
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_SB: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_SB;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ////////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 ///////
          crtl_regb = 1'b1;                 ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_SB;

          crtl_ulasrca = 1'b1;            //////
          crtl_ulasrcb = 2'b10;           //////        
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                 ///////
          crtl_regb = 1'b0;                 ///////
          crtl_regaluout = 1'b1;            ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_SB;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;              ////////          
          crtl_memwrite = 1'b1;           ////////       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b10;                /////////
          crtl_irwrite = 1'b0;            
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;             ////////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000011) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_SH: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_SH;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ////////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 ///////
          crtl_regb = 1'b1;                 ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_SH;

          crtl_ulasrca = 1'b1;            //////
          crtl_ulasrcb = 2'b10;           //////        
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                 ///////
          crtl_regb = 1'b0;                 ///////
          crtl_regaluout = 1'b1;            ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_SH;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;              ////////          
          crtl_memwrite = 1'b1;           ////////       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b01;                /////////
          crtl_irwrite = 1'b0;            
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;             ////////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000011) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_SW: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_SW;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;             ////////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 ///////
          crtl_regb = 1'b1;                 ///////
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_SW;

          crtl_ulasrca = 1'b1;            //////
          crtl_ulasrcb = 2'b10;           //////        
          crtl_aluop = 3'b001;            /////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;                 ///////
          crtl_regb = 1'b0;                 ///////
          crtl_regaluout = 1'b1;            ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000010) begin
          STATE = ST_SW;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b10;              ////////          
          crtl_memwrite = 1'b1;           ////////       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;                /////////
          crtl_irwrite = 1'b0;            
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;             ////////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000011) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_SLTI: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_SLTI;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0110;
          crtl_regwrite = 1'b1;           ///////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b1;                 ///////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;
          
          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b1;            ///////       
          crtl_ulasrcb = 2'b10;           ///////
          crtl_aluop = 3'b111;            //////          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;           //////
          crtl_memtoreg = 4'b0110;       ///////
          crtl_regwrite = 1'b1;           //////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;               ///////
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_J: begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b100;           ///////    
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;                       
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;              ///////
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
      ST_JAL:begin
        if (COUNTER == 6'b000000) begin
          STATE = ST_JAL;
          
          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b100;         //////
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b000;
          crtl_memtoreg = 4'b0000;
          crtl_regwrite = 1'b0;
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b1;            //////        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b1;          //////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = COUNTER + 1;
        end else if (COUNTER == 6'b000001) begin
          STATE = ST_COMMON;

          crtl_ulasrca = 1'b0;        
          crtl_ulasrcb = 2'b00;        
          crtl_aluop = 3'b000;          
          crtl_pcsource = 3'b000;     
          crtl_iord = 2'b00;          
          crtl_memwrite = 1'b0;       
          crtl_error = 2'b00;
          crtl_insfht = 2'b00;
          crtl_ss = 2'b00;
          crtl_irwrite = 1'b0;        
          crtl_regdst = 3'b100;           //////
          crtl_memtoreg = 4'b0010;        //////
          crtl_regwrite = 1'b1;           //////
          crtl_ls = 1'b0;
          crtl_muxshf = 2'b00;
          crtl_setmd = 1'b0;
          crtl_pcwritecond = 1'b0;
          crtl_pcwrite = 1'b0;        
          crtl_sideshifter = 3'b000;
          crtl_memDataRegWrite = 1'b0;
          crtl_rega = 1'b0;
          crtl_regb = 1'b0;
          crtl_regaluout = 1'b0;        ///////
          crtl_regepc = 1'b0;
          crtl_reghigh = 1'b0;
          crtl_reglow = 1'b0;

          COUNTER = 0;
        end
      end
    endcase
  end
end

endmodule