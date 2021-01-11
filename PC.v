`timescale 1ns / 1ps

module PCLogic(NextPC, CurrPC, SignExtImm64, Branch, ALUZero, ZorNZ, Unconditional, WriteEn, Clk);
    input Branch, Unconditional, ALUZero, WriteEn, ZorNZ, Clk;
    input [63:0] SignExtImm64, CurrPC;
    output reg [63:0] NextPC;

     always@(*)
        if(WriteEn) begin
            // $display("Enabled");
            // if(Branch)
            //     $display("branch is true.");
            // if(ALUZero)
            //     $display("ALU Zero is true");
            if((Branch && ALUZero && ZorNZ) || (Branch && !ALUZero && !ZorNZ) || Unconditional) begin // Branching logic
                // $display("SignExtImm64: %d %b", $signed(SignExtImm64), SignExtImm64);
                // $display("BRNACHING");
                NextPC = SignExtImm64;
            end
            else
                NextPC = CurrPC + 4;
        end
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
        BranchPC <= $signed(CurrentPC) + $signed(ExtendedImm <<< 2);
    end
endmodule