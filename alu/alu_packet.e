<'
-- ================================================= --
--   alu_packet.e : transaction (1 ALU Operation)
-- ================================================= --

-- Opcode Types
type alu_op_t : [ ADD, SUB, AND, OR ] (bits:2);

struct alu_packet_s {

  -- Fields
  a  : uint (bits:8);
  b  : uint (bits:8);
  op : alu_op_t;
  
  -- Constraints
  -- Using keep soft for default values
  keep soft a in [0..255];
  keep soft b in [0..255];
  
  -- Using hard constraint on b when op is SUB
  keep (op == SUB) => (b != 0);
  
  -- Do not randomize for fields with !
  -- Generate value
  !expected_result : uint (bits:9);
  
  post_generate() is also {
    case op {
      ADD: { expected_result = (a + b) & 0x1FF; };
      SUB: { expected_result = (a - b) & 0x1FF; };
      AND: { expected_result = a & b; };
      OR : { expected_result = a | b; };
    };
  };
  
  to_string() : string is also {
    result = appendf("PKT[op=%s a=0x%02x b=0x%02x exp=0x%03x]", op, a, b, expected_result);
  };

}; -- alu_packet_s

'>