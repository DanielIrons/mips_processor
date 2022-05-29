`include "Controller.v"
`include "SignExtender.v"
`include "RegisterFile.v"
`include "PC.v"
`include "InstructionMemory.v"
`include "DataMemory.v"
`include "ALU.v"
`include "3To1Mux.v"
`include "2To1Mux.v"
`include "ForwardingUnit.v"
`include "HazardDetectionUnit.v"

`timescale 1ns / 1ps

module processor(resetl, startpc, currentpc, WB_data, instructionOut, Clk);
    input resetl;
    input [63:0] startpc;
    output reg [63:0] currentpc;	  // For debug purposes
    output wire [63:0] WB_data;		  // For debug purposes
    output reg [31:0] instructionOut; // For debug purposes
    input Clk;

    // Next PC connections
    wire [63:0] nextPC;       // The next PC, to be updated on clock cycle

    // Instruction Memory connections
    wire [31:0] instruction;  // The current instruction

    // Control wires
    wire reg2loc, alusrc, mem2reg, regwrite, memread, memwrite, branch, uncond_branch;
    wire [1:0] aluop;
    wire [3:0] aluctrl;
    wire [2:0] signop;

    // Register file connections
    wire [63:0] regoutA, regoutB;

    // ALU connections
    wire [63:0] ALUinA, ALUinB, aluout;
    wire zero;

    // Sign Extender connections
    wire [63:0] ExtendedImm;

    wire [10:0] IFIDop, IDEXop;
    wire [4:0] IFIDrd, IFIDrm, IFIDrn, IDEXrn, IDEXrm, IDEXrd, EXMEMrd, MEMWBrd;

    wire [1:0] ForwardA, ForwardB;

    wire [63:0] dmemout, ALUBIn1Choice;

    wire PC_WriteEn, IFID_WriteEn, Control_Sel;

    wire [63:0] BranchPC;

    // Registers for inter-stage storage
    reg [63:0] IFIDPC, IDEXPC, EXMEMPC;
    reg [31:0] IFIDIR, IDEXIR, EXMEMIR, MEMWBIR;

    reg [1:0] IDEXWB; // [0] writereg, [1] mem2reg
    reg [4:0] IDEXM; // [0] memread, [1] memwrite, [2] branch, [3] unconditional branch, [4] ZorNZ
    reg [3:0] IDEXEX; // [0] aluop[0], [1] aluop[1]
    reg [63:0] IDEXA, IDEXB, IDEXExtImm;
    reg IDEXALUop;

    reg [1:0] EXMEMWB;
    reg [4:0] EXMEMM;
    reg [63:0] EXMEMALUout, EXMEMB;
    reg EXMEMZero;
    
    reg [1:0] MEMWBWB;
    reg [63:0] MEMWBrData, MEMWBALUout;

    // PC update logic
    always @(negedge Clk)
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
    always @(posedge Clk)
    begin
        $display("Current Instruction: %h", IFIDIR);
        $display("Next PC: %h", currentpc);
        if (resetl)
        begin
            if(IFID_WriteEn) begin
                IFIDPC <= currentpc;
                IFIDIR <= instruction;
            end
            if(Control_Sel == 0) begin 
                IDEXWB[0] <= regwrite;
                IDEXWB[1] <= mem2reg;
                IDEXALUop <= alusrc;
                IDEXM[0] <= memread;
                IDEXM[1] <= memwrite;
                IDEXM[2] <= branch;
                IDEXM[3] <= uncond_branch;
                IDEXM[4] <= zornz;
                IDEXEX[3:0] <= aluctrl;
            end
            else begin
                IDEXWB[0] <= 0;
                IDEXWB[1] <= 0;
                IDEXALUop <= 0;
                IDEXM <= 0;
                IDEXEX[3:0] <= 0;
            end

            IDEXIR <= IFIDIR;
            IDEXPC <= IFIDPC;
            IDEXA <= regoutA;
            IDEXB <= regoutB;
            IDEXExtImm <= ExtendedImm;

            EXMEMIR <= IDEXIR;
            EXMEMWB <= IDEXWB;
            EXMEMM <= IDEXM;
            EXMEMZero <= zero;
            EXMEMALUout <= aluout;
            EXMEMB <= IDEXB;
            EXMEMPC <= BranchPC;

            MEMWBIR <= EXMEMIR;
            MEMWBWB <= EXMEMWB;
            MEMWBrData <= dmemout;
            MEMWBALUout <= EXMEMALUout;
        end       
    end

    assign IFIDrd = IFIDIR[4:0];
    assign IFIDrm = IFIDIR[9:5];
    assign IFIDrn = IFIDIR[28] ? IFIDIR[4:0] : IFIDIR[20:16];
    assign IFIDop = IFIDIR[31:21];

    assign IDEXrd = IDEXIR[4:0];
    assign IDEXrm = IDEXIR[9:5];
    assign IDEXrn = IDEXIR[28] ? IDEXIR[4:0] : IDEXIR[20:16];
    assign IDEXop = IDEXIR[31:21];

    assign EXMEMrd = EXMEMIR[4:0];

    assign MEMWBrd = MEMWBIR[4:0];

    PCLogic PCLogic(
        .NextPC(nextPC),
        .CurrPC(currentpc),
        .SignExtImm64(EXMEMPC),
        .Branch(EXMEMM[2]),
        .ALUZero(EXMEMZero),
        .Unconditional(EXMEMM[3]),
        .ZorNZ(EXMEMM[4]),
        .WriteEn(PC_WriteEn)
    );

    BranchPC branchPC(
        .BranchPC(BranchPC),
        .ExtendedImm(IDEXExtImm),
        .CurrentPC(IDEXPC)
    );

    ForwardingUnit FU(
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .Branching(EXMEMM[2] | EXMEMM[3] | IDEXM[2] | IDEXM[3]),
        .EXMEM_RegWrite(EXMEMWB[0]),
        .MEMWB_RegWrite(MEMWBWB[0]),
        .EXMEMrd(EXMEMrd),
        .MEMWBrd(MEMWBrd),
        .IDEX_rm(IDEXrm),
        .IDEX_rn(IDEXrn)
    );

    HazardDetectionUnit hdu(
        .PC_WriteEn(PC_WriteEn),
        .IFID_WriteEn(IFID_WriteEn),
        .Stall_flush(Control_Sel),
        .IDEX_MemRead(IDEXM[0]),
        .IDEX_rd(IDEXrd),
        .IFID_rn(IFIDrn),
        .IFID_rm(IFIDrm),
        .IFID_rd(IFIDrd)
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
        .zornz(zornz),
        .aluop(aluctrl),
        .signop(signop),
        .opcode(IFIDop)
    );

    RegisterFile RegisterFile(
        .BusA(regoutA),
        .BusB(regoutB),
        .BusW(WB_data),
        .RA(IFIDrm),
        .RB(IFIDrn),
        .RW(MEMWBrd),
        .RegWr(MEMWBWB[0])
    );

    SignExtender SignExtender(
        .BusImm(ExtendedImm),
        .Imm26(IFIDIR[25:0]),
        .Ctrl(signop)
    );

    Mux2to1 ALUB_in1_src(
        .out(ALUinB),
        .in1(ALUBIn1Choice),
        .in2(IDEXExtImm),
        .ctrl(IDEXALUop)
    );

    Mux3to1 ALUB(
        .out(ALUBIn1Choice),
        .in1(IDEXB),
        .in2(WB_data),
        .in3(EXMEMALUout),
        .ctrl(ForwardB),
        .en(1'b1)
    );

    Mux3to1 ALUA(
        .out(ALUinA),
        .in1(IDEXA),
        .in2(WB_data),
        .in3(EXMEMALUout),
        .ctrl(ForwardA),
        .en(1'b0)
    );

    ALU ALU(
        .BusW(aluout),
        .BusA(ALUinA),
        .BusB(ALUinB),
        .ALUCtrl(IDEXEX),
        .Zero(zero)
    );

    Mux2to1 Memory_WB_Mux(
        .out(WB_data),
        .in1(MEMWBALUout),
        .in2(MEMWBrData),
        .ctrl(MEMWBWB[1])
    );

    DataMemory DataMemory(
        .ReadData(dmemout),
        .Address(EXMEMALUout),
        .WriteData(EXMEMB),
        .MemoryRead(EXMEMM[0]),
        .MemoryWrite(EXMEMM[1]),
        .Clock(Clk)
    );
endmodule