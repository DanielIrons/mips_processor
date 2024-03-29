`timescale 1ns / 1ps

module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr);
    output [63:0] BusA, BusB;
    input [4:0] RW, RA, RB;
    input [63:0] BusW;
    input RegWr;
    reg [63:0] registers [31:0];

    integer i;
    initial begin
       for (i = 0; i<64; i=i+1) begin
            registers[i] = 0;
        end
    end
     
    assign BusA = (RA == 31) ? 0 : registers[RA]; // Assign out put to register RA
    assign BusB = (RB == 31) ? 0 : registers[RB]; // Assign other output to be register RB
     
    always@ (*) begin // On the negative edge
        if(RegWr && RW != 31) begin
            #1 registers[RW] <= BusW;
        end
    end
endmodule