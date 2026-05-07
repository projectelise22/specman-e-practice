// alu.v  —  8-bit ALU DUT
module alu (
    input        clk,
    input        rst_n,
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] op,      // 00=ADD 01=SUB 10=AND 11=OR
    input        valid,
    output reg [8:0] result,
    output reg       done
);
 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 9'b0;
        done   <= 1'b0;
    end else if (valid) begin
        done <= 1'b1;
        case (op)
            2'b00: result <= a + b;
            2'b01: result <= a - b;
            2'b10: result <= a & b;
            2'b11: result <= a | b;
        endcase
    end else begin
        done <= 1'b0;
    end
end
endmodule

module top;

    logic clk;
    logic rst_n;
    logic [7:0] a;
    logic [7:0] b;
    logic [1:0] op;
    logic valid;
    logic [8:0] result;
    logic done;

    alu alu (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .op(op),
        .valid(valid),
        .result(result),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

endmodule