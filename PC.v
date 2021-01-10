`timescale 1ns / 1ps

module PCLogic(NextPC, CurrPC, SignExtImm64, Branch, ALUZero, Unconditional, WriteEn, Clk);
    input Branch, Unconditional, ALUZero, WriteEn, Clk;
    input [63:0] SignExtImm64, CurrPC;
    output reg [63:0] NextPC;

     always@(posedge Clk)
        if(WriteEn)
            if((Branch && ALUZero) || Unconditional) begin // Branching logic
                // $display("Unconditional. SignExtImm64: %d %b", $signed(SignExtImm64), SignExtImm64);
                // $display("branching");
                NextPC = SignExtImm64;
            end
            else
                NextPC = CurrPC + 4;
        else
            NextPC = CurrPC;
endmodule

module BranchPC(BranchPC, ExtendedImm, CurrentPC, Clk);
    input [63:0] ExtendedImm;
    input [63:0] CurrentPC;
    input Clk;
    output reg [63:0] BranchPC;

    always@(*) begin
        // $display("ExtendedImm: %d %b", $signed(ExtendedImm), $signed(ExtendedImm));
        // $display("CurrentPC: %d BranchPC: %d", CurrentPC, $signed(BranchPC));
        BranchPC <= CurrentPC + $signed(ExtendedImm <<< 2);
    end
endmodule