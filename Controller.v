`timescale 1ns / 1ps

`define OPCODE_ANDREG 11'b10001010000
`define OPCODE_ORRREG 11'b10101010000
`define OPCODE_ADDREG 11'b10001011000
`define OPCODE_SUBREG 11'b11001011000

`define OPCODE_ADDIMM 11'b1001000100x
`define OPCODE_SUBIMM 11'b1101000100x

`define OPCODE_MOVZ   11'b110100101xx

`define OPCODE_B      11'b000101xxxxx
`define OPCODE_CBZ    11'b10110100xxx
`define OPCODE_CBNZ    11'b10110101xxx

`define OPCODE_LDUR   11'b11111000010
`define OPCODE_STUR   11'b11111000000

module control(reg2loc, alusrc, mem2reg, regwrite, memread, memwrite, branch, uncond_branch, zornz, aluop, signop, opcode, Clk);
   
    output reg reg2loc;
    output reg alusrc;
    output reg mem2reg;
    output reg regwrite;
    output reg memread;
    output reg memwrite;
    output reg branch;
    output reg uncond_branch;
    output reg zornz;
    output reg [3:0] aluop;
    output reg [2:0] signop;
    input [10:0] opcode;
    input wire Clk;

    always @(*)
    begin
        casex (opcode)

            `OPCODE_ANDREG:
            begin
                reg2loc       <= 1'b0;
                alusrc        <= 1'b0;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0000;
                signop        <= 2'b00;
            end
            `OPCODE_ORRREG:
            begin
                reg2loc       <= 1'b0;
                alusrc        <= 1'b0;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0001;
                signop        <= 2'b00;
            end
            `OPCODE_ADDREG:
            begin
                reg2loc       <= 1'b0;
                alusrc        <= 1'b0;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0010;
                signop        <= 2'b00;
            end
            `OPCODE_SUBREG:
            begin
                reg2loc       <= 1'b0;
                alusrc        <= 1'b0;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0110;
                signop        <= 2'b00;
            end
            `OPCODE_ADDIMM:
            begin
                reg2loc       <= 1'b0;
                alusrc        <= 1'b1;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0010;
                signop        <= 2'b00;
            end
            `OPCODE_SUBIMM:
            begin
                reg2loc       <= 1'b0;
                alusrc        <= 1'b1;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0110;
                signop        <= 2'b00;
            end
            `OPCODE_MOVZ:
            begin
                reg2loc       <= 1'bx;
                alusrc        <= 1'b1;
                mem2reg       <= 1'b0;
                regwrite      <= 1'b1;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b1000;
                signop        <= 3'b1xx;
            end
            `OPCODE_B:
            begin
                $display("Unconditional Branch");
                reg2loc       <= 1'bx;
                alusrc        <= 1'bx;
                mem2reg       <= 1'bx;
                regwrite      <= 1'b0;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'bx;
                uncond_branch <= 1'b1;
                aluop         <= 4'bxxxx;
                signop        <= 2'b10;
            end
            `OPCODE_CBZ:
            begin
                $display("Conditional Branch");
                reg2loc       <= 1'b1;
                alusrc        <= 1'b0;
                mem2reg       <= 1'bx;
                regwrite      <= 1'b0;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b1;
                uncond_branch <= 1'b0;
                zornz         <= 1'b1;
                aluop         <= 4'b0111;
                signop        <= 2'b11;
            end
            `OPCODE_CBNZ:
            begin
                $display("Conditional Branch");
                reg2loc       <= 1'b1;
                alusrc        <= 1'b0;
                mem2reg       <= 1'bx;
                regwrite      <= 1'b0;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b1;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0111;
                signop        <= 2'b11;
            end
            `OPCODE_LDUR:
            begin
                reg2loc       <= 1'bx;
                alusrc        <= 1'b1;
                mem2reg       <= 1'b1;
                regwrite      <= 1'b1;
                memread       <= 1'b1;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0010;
                signop        <= 2'b01;
            end
            `OPCODE_STUR:
            begin
                reg2loc       <= 1'b1;
                alusrc        <= 1'b1;
                mem2reg       <= 1'bx;
                regwrite      <= 1'b0;
                memread       <= 1'b0;
                memwrite      <= 1'b1;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'b0010;
                signop        <= 2'b01;
            end

            default:
            begin
                reg2loc       <= 1'bx;
                alusrc        <= 1'bx;
                mem2reg       <= 1'bx;
                regwrite      <= 1'b0;
                memread       <= 1'b0;
                memwrite      <= 1'b0;
                branch        <= 1'b0;
                uncond_branch <= 1'b0;
                zornz         <= 1'b0;
                aluop         <= 4'bxxxx;
                signop        <= 2'bxx;
            end
        endcase
    end
endmodule