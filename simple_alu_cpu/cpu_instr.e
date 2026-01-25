<'
type cpu_opcode_t: [ //Opcodes
    ADD, ADDI, SUB, SUBI,
    AND, ANDI, XOR, XORI,
    JMP, JMPC, CALL, RET,
    NOP
] (bits: 4);

type cpu_reg_t: [
    REG0, REG1, REG2, REG3
] (bits: 2);

struct cpu_instr_s {
	//defines opcode, operand 1 and instruction kind
    %opcode   : cpu_opcode_t;
    %op1 : cpu_reg_t;
    kind      : [imm, reg];
    
    //defines operand 2 of register instruction
    when reg cpu_instr_s {
        %op2 : cpu_reg_t;
    };
    
    //defines operand 2 of immediate instruction
    when imm cpu_instr_s {
        %op2 : cpu_reg_t;
    };
    
    //defines legal opcodes for register instruction
    keep opcode in [ADD, SUB, AND, XOR, RET, NOP] => kind == reg;
    
    //defines legal opcodes for immediate instruction
    keep opcode in [ADDI, SUBI, ANDI, XORI, JMP, JMPC, CALL] => kind == imm;  
    
    //ensures 4-bit addressing scheme
    when imm cpu_instr_s {
        keep read_only(opcode in [JMP, JMPC, CALL]) => op2 < 16; 
    };
};

extend sys {
    //instructions for sys
    !instrs: list of cpu_instr_s;
}
'>