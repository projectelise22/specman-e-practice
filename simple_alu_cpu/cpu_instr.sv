typedef enum logic [3:0] {
    ADD   = 4'd0,
    ADDI  = 4'd1,
    SUB   = 4'd2,
    SUBI  = 4'd3,
    AND   = 4'd4,
    ANDI  = 4'd5,
    XOR   = 4'd6,
    XORI  = 4'd7,
    JMP   = 4'd8,
    JMPC  = 4'd9,
    CALL  = 4'd10,
    RET   = 4'd11,
    NOP   = 4'd12
} cpu_opcode_t;

typedef enum logic [1:0] {
    REG0 = 2'd0,
    REG1 = 2'd1,
    REG2 = 2'd2,
    REG3 = 2'd3
} cpu_reg_t;

typedef enum logic {
    IMM,
    REG
} instr_kind_t;


class cpu_instr_s;

    rand cpu_opcode_t opcode;
    rand cpu_reg_t    op1;
    rand cpu_reg_t    op2;
    rand instr_kind_t kind;

    // -------------------------
    // Opcode → instruction kind
    // -------------------------

    constraint opcode_kind_reg_c {
        (opcode inside {ADD, SUB, AND, XOR, RET, NOP}) -> kind == REG;
    }

    constraint opcode_kind_imm_c {
        (opcode inside {ADDI, SUBI, ANDI, XORI, JMP, JMPC, CALL}) -> kind == IMM;
    }

    // -------------------------
    // Immediate instruction rule
    // -------------------------
    // Specman note:
    // "ensures 4-bit addressing scheme"
    constraint imm_addr_c {
        if (kind == IMM && opcode inside {JMP, JMPC, CALL}) {
            op2 < 16;
        }
    }

    function void display();
        $display("Instruction: %0s | op1=%0s op2=%0d kind=%0s", 
        opcode.name(), op1.name(), op2, (kind==REG)?"REG":"IMM");
    endfunction
endclass
