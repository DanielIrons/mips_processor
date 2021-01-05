`timescale 1ns / 1ps

module PCLogic(NextPC, CurrPC, SignExtImm64, Branch, ALUZero, Unconditional, WriteEn);
    input Branch, Unconditional, ALUZero, WriteEn;
    input [63:0] SignExtImm64, CurrPC;
    output reg [63:0] NextPC;

     always@(*)
        if(WriteEn)
            if((Branch && ALUZero) || Unconditional) // Branching logic
                NextPC = SignExtImm64;
            else
                NextPC = CurrPC + 4;
        else
            NextPC = CurrPC;
endmodule

module BranchPC(BranchPC, ExtendedImm, CurrentPC, Clk);
    input [63:0] ExtendedImm;
    input [63:0] CurrentPC;
    input Clk;
    output reg BranchPC;

    always@(posedge Clk) begin
         BranchPC <= CurrentPC + (ExtendedImm << 2);
    end
endmodule