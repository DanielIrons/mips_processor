`timescale 1ns / 1ps

module PCLogic(NextPC, CurrPC, SignExtImm64, Branch, ALUZero, ZorNZ, Unconditional, WriteEn, Clk);
    input Branch, Unconditional, ALUZero, WriteEn, ZorNZ, Clk;
    input [63:0] SignExtImm64, CurrPC;
    output reg [63:0] NextPC;

     always@(*)
        if(WriteEn) begin
            if((Branch && ALUZero && ZorNZ) || (Branch && !ALUZero && !ZorNZ) || Unconditional) begin // Branching logic
                NextPC = SignExtImm64;
            end
            else
                NextPC = CurrPC + 4;
        end
        else
            NextPC = CurrPC;
endmodule

module BranchPC(BranchPC, ExtendedImm, CurrentPC);
    input [63:0] ExtendedImm;
    input [63:0] CurrentPC;
    output reg [63:0] BranchPC;

    always@(*) begin
        BranchPC <= $signed(CurrentPC) + $signed(ExtendedImm <<< 2);
    end
endmodule