<'
import cpu_top;

// =========================
// Test Environment Check
// =========================
// Simple test to check working testbench
// Operation: ADD and ADDI
// Generate 5 tests within these operations
// - When ADD, use op1 = REG0 and op2 = REG1
// - When ADD1, use op2 = 0x5 as immediate value

// Update test constraints
extend cpu_instr_s {
    keep opcode in [ADD, ADDI];
    keep op1 == REG0;
    when reg cpu_instr_s { keep op2 == REG1; };
    when imm cpu_instr_s { keep op2 == 0x5; };
};

// Generate random 5 tests based on constraints above
extend sys {
    keep instrs.size() == 5;
};


'>