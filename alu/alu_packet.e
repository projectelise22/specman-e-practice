<'
-- ================================================= --
--   alu_packet.e
--   PURPOSE: Transaction data object (struct = data, not time-aware)
-- ================================================= --
type alu_op_t : [ADD, SUB, AND_OP, OR_OP] (bits:2);

struct alu_packet_s {
    a  : uint (bits:8);
    b  : uint (bits:8);
    op : alu_op_t;

    keep soft a in [0..255];
    keep soft b in [0..255];
    keep (op == SUB) => (b != 0);   -- hard constraint: no zero subtraction

    !expected_result : uint (bits:9);  -- ! = do not randomize

    post_generate() is also {          -- runs automatically after gen
        case op {
            ADD    : { expected_result = (a + b) & 0x1FF; };
            SUB    : { expected_result = (a - b) & 0x1FF; };
            AND_OP : { expected_result = a & b; };
            OR_OP  : { expected_result = a | b; };
        };
    };

    to_string() : string is also {
        result = appendf("PKT[op=%s a=0x%02x b=0x%02x exp=0x%03x]",
                         op, a, b, expected_result);
    };
};
'>