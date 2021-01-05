module Mux2to1_23b(out, in1, in2, ctrl);
    output reg [22:0] out;
    input [22:0] in1, in2;
    input ctrl;

    always @(*)
        if (ctrl == 1'b0)
            out <= in1;
        else if (ctrl  == 1'b1)
            out <= in2;

endmodule