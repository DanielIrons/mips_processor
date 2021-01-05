module BitShifter(out, in, shift_value, shift_dir, clk);
    output reg [22:0] out;
    input [22:0] in;
    input [7:0] shift_value;
    input shift_dir;
    input clk;

    always@(clk)
        if(shift_dir == 1'b0)
            out <= in << shift_value;
        else
            out <= in >> shift_value;

endmodule