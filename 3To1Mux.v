module Mux3to1(out, in1, in2, in3, ctrl, en);
    output reg [63:0] out;
    input [63:0] in1, in2, in3;
    input [1:0] ctrl;
    input en;

    always @(*) begin
    if (ctrl == 2'b00)
        out <= in1;
    else if (ctrl  == 2'b01)
        out <= in2;
    else if (ctrl  == 2'b10)
        out <= in3;
    end

endmodule