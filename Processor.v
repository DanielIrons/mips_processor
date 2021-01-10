`include "Controller.v"
`include "SignExtender.v"
`include "RegisterFile.v"
`include "PC.v"
`include "InstructionMemory.v"
`include "DataMemory.v"
`include "ALU.v"
`include "3To1Mux.v"
`include "2To1Mux.v"
`include "ForwardingUnitSequential.v"
`include "HazardDetectionUnit.v"

`timescale 1ns / 1ps

module processor(resetl, startpc, currentpc, WB_data, instructionOut, IFID_instruction_debug, CLK);
    input resetl;
    input [63:0] startpc;
    output reg [63:0] currentpc;	  // For debug purposes
    output wire [63:0] WB_data;		  // For debug purposes
    output reg [31:0] instructionOut; // For debug purposes
    output reg [31:0] IFID_instruction_debug;
    input CLK;

    // Next PC connections
    wire [63:0] nextPC;       // The next PC, to be updated on clock cycle

    // Instruction Memory connections
    wire [31:0] instruction;  // The current instruction

    // Parts of instruction
    wire [4:0] rd;            // The destination register
    wire [4:0] rm;            // Operand 1
    wire [4:0] rn;            // Operand 2
    wire [10:0] opcode;

    // Control wires
    wire reg2loc;
    wire alusrc;
    wire mem2reg;
    wire regwrite;
    wire memread;
    wire memwrite;
    wire branch;
    wire [1:0] aluop;
    wire uncond_branch;
    wire [3:0] aluctrl;
    wire [2:0] signop;

    // Register file connections
    wire [63:0] regoutA;     // Output A
    wire [63:0] regoutB;     // Output B

    // ALU connections
    wire [63:0] ALUinA;
    wire [63:0] ALUinB;
    wire [63:0] aluout;
    wire zero;

    // Sign Extender connections
    wire [63:0] extimm;

    // wire [63:0] WB_data;
    wire [4:0] WB_Register;

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    wire [63:0] WriteBackData;
    wire [63:0] dmemout;
    wire [63:0] ALUB_in1_choice;

    wire PC_WriteEn;
    wire IFID_WriteEn;
    wire Control_Sel;

    wire [63:0] BranchPC;

    // Registers for inter-stage storage
    reg [63:0] IFID_PC;
    reg [31:0] IFID_instruction;

    reg [1:0] IDEX_WB; // [0] writereg, [1] mem2reg
    reg [3:0] IDEX_M; // [0] memread, [1] memwrite, [2] branch, [3] unconditional branch
    reg [3:0] IDEX_EX; // [0] aluop[0], [1] aluop[1]
    reg [63:0] IDEX_PC;
    reg [63:0] IDEX_rDataA;
    reg [63:0] IDEX_rDataB;
    reg [63:0] IDEX_SignExtender;
    reg [10:0] IDEX_ALUfield;
    reg IDEX_ALUop;
    reg [4:0] IDEX_WReg;
    reg [4:0] IDEX_rn;
    reg [4:0] IDEX_rm;

    reg [1:0] EXMEM_WB;
    reg [3:0] EXMEM_M;
    reg [63:0] EXMEM_PC;
    reg EXMEM_Zero;
    reg [63:0] EXMEM_ALUout;
    reg [63:0] EXMEM_rDataB;
    reg [4:0] EXMEM_WReg;

    reg [1:0] MEMWB_WB;
    reg [63:0] MEMWB_rData;
    reg [63:0] MEMWB_ALUout;
    reg [4:0] MEMWB_WReg;

    // PC update logic
    always @(negedge CLK)
    begin
      	if (resetl) 
      	begin 
            currentpc <= nextPC;
      		instructionOut <= instruction;
      	end
      	else begin
            currentpc <= startpc;
        end
    end

    // Update intermediary registers
    always @(posedge CLK)
    begin
        // $display("IFID_Instruction: %h IDEX_rm: %d IDEX_rn: %d EXMEM_Write_Reg: %d, EXMEM_rd: %d, MEMWB_Write_Reg: %d, MEMWB_rd: %d", 
        // IFID_instruction, IDEX_rm, IDEX_rn, EXMEM_WB[0], EXMEM_WReg, MEMWB_WB[0], MEMWB_WReg);
        // $display("EXMEM_ALUout: %d, MEMWB_ALUout: %d", EXMEM_ALUout, MEMWB_ALUout);
        $display("Instruction: %h", instruction);
        $display("Current PC: %h", currentpc);
        if (resetl)
        begin
            if(IFID_WriteEn) begin
                // $display("Updated IFID");
                IFID_PC <= currentpc;
                IFID_instruction <= instruction;
                IFID_instruction_debug <= instruction;
            end
            if(Control_Sel == 0) begin 
                IDEX_WB[0] <= regwrite;
                IDEX_WB[1] <= mem2reg;
                IDEX_ALUop <= alusrc;
                IDEX_WReg <= IFID_instruction[4:0];
                IDEX_M[0] <= memread;
                IDEX_M[1] <= memwrite;
                IDEX_M[2] <= branch;
                IDEX_M[3] <= uncond_branch;
                IDEX_EX[3:0] <= aluctrl;
            end
            else begin
                IDEX_WB[0] <= 0;
                IDEX_WB[1] <= 0;
                IDEX_ALUop <= 0;
                IDEX_WReg <= 0;
                IDEX_M[0] <= 0;
                IDEX_M[1] <= 0;
                IDEX_M[2] <= 0;
                IDEX_EX[3:0] <= 0;
            end
            IDEX_PC <= IFID_PC;
            IDEX_rDataA <= regoutA;
            IDEX_rDataB <= regoutB;
            IDEX_SignExtender <= extimm;
            IDEX_ALUfield <= instruction[31:21];
            IDEX_rm <= rm;
            IDEX_rn <= rn;

            EXMEM_WB <= IDEX_WB;
            EXMEM_M <= IDEX_M;
            EXMEM_PC <= nextPC;
            EXMEM_Zero <= zero;
            EXMEM_ALUout <= aluout;
            EXMEM_rDataB <= IDEX_rDataB;
            EXMEM_WReg <= IDEX_WReg;
            EXMEM_PC <= BranchPC;

            MEMWB_WB <= EXMEM_WB;
            MEMWB_rData <= dmemout;
            MEMWB_ALUout <= EXMEM_ALUout;
            MEMWB_WReg <= EXMEM_WReg;
        end       
    end

    // Parts of instruction
    assign rd = IFID_instruction[4:0];
    assign rm = IFID_instruction[9:5];
    assign rn = IFID_instruction[28] ? IFID_instruction[4:0] : IFID_instruction[20:16];
    assign opcode = IFID_instruction[31:21];

    ForwardingUnit FU(
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB), 
        .Branching(EXMEM_M[2] | EXMEM_M[3] | IDEX_M[2] | IDEX_M[3]),
        .EXMEM_RegWrite(EXMEM_WB[0]), 
        .MEMWB_RegWrite(MEMWB_WB[0]), 
        .EXMEM_WriteRegister(EXMEM_WReg), 
        .MEMWB_WriteRegister(MEMWB_WReg), 
        .IDEX_rm(IDEX_rm),
        .IDEX_rn(IDEX_rn),
        .Clk(CLK)
    );

    HazardDetectionUnit hdu(
        .PC_WriteEn(PC_WriteEn), .IFID_WriteEn(IFID_WriteEn), 
        .Stall_flush(Control_Sel), .IDEX_MemRead(IDEX_M[0]), 
        .IDEX_rd(IDEX_WReg), .IFID_rn(rn), 
        .IFID_rm(rm), .IFID_rd(rd), .Clk(CLK)
    );

    InstructionMemory imem(
        .Data(instruction),
        .Address(currentpc)
    );

    control control(
        .reg2loc(reg2loc),
        .alusrc(alusrc),
        .mem2reg(mem2reg),
        .regwrite(regwrite),
        .memread(memread),
        .memwrite(memwrite),
        .branch(branch),
        .uncond_branch(uncond_branch),
        .aluop(aluctrl),
        .signop(signop),
        .opcode(opcode),
        .Clk(CLK)
    );

    RegisterFile RegisterFile(
        .BusA(regoutA), .BusB(regoutB), .BusW(WB_data),
        .RA(rm), .RB(rn), .RW(MEMWB_WReg),
        .RegWr(MEMWB_WB[0]), .Clk(CLK)
    );

    SignExtender SignExtender(
        .BusImm(extimm), .Imm26(IFID_instruction[25:0]), .Ctrl(signop), .Clk(CLK)
    );

    Mux2to1 ALUB_in1_src(
        .out(ALUinB), .in1(ALUB_in1_choice), .in2(IDEX_SignExtender), .ctrl(IDEX_ALUop)
    );

    Mux3to1 ALUB(
        .out(ALUB_in1_choice), .in1(IDEX_rDataB), .in2(WB_data), .in3(EXMEM_ALUout), .ctrl(ForwardB), .Clk(CLK), .en(1'b1)
    );

    Mux3to1 ALUA(
        .out(ALUinA), .in1(IDEX_rDataA), .in2(WB_data), .in3(EXMEM_ALUout), .ctrl(ForwardA), .Clk(CLK), .en(1'b0)
    );

    ALU ALU(
        .BusW(aluout), .BusA(ALUinA), .BusB(ALUinB), .ALUCtrl(IDEX_EX), .Zero(zero), .Clk(CLK)
    );

    Mux2to1 Memory_WB_Mux(
        .out(WB_data), .in1(MEMWB_ALUout), .in2(MEMWB_rData), .ctrl(MEMWB_WB[1])
    );

    DataMemory DataMemory(
        .ReadData(dmemout), .Address(EXMEM_ALUout), 
        .WriteData(EXMEM_rDataB), .MemoryRead(EXMEM_M[0]), 
        .MemoryWrite(EXMEM_M[1]), .Clock(CLK)
    );

    BranchPC branchPC(
        .BranchPC(BranchPC), .ExtendedImm(IDEX_SignExtender), .CurrentPC(IDEX_PC), .Clk(CLK)
    );

    PCLogic PCLogic(
        .NextPC(nextPC), 
        .CurrPC(currentpc), .SignExtImm64(EXMEM_PC), 
        .Branch(EXMEM_M[2]), .ALUZero(EXMEM_Zero), .Unconditional(EXMEM_M[3]),
        .WriteEn(PC_WriteEn), .Clk(CLK)
    );
endmodule