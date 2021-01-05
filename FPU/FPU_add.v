`timescale 1ns / 1ps

`include "2To1Mux_23b.v"
`include "2To1Mux_8b.v"
`include "ALU_8b.v"
`include "ALU_23b.v"
`include "BitShifter.v"
`include "FPUAddController.v"

module FPU_add(BusW, BusA, BusB, clk);
    output wire [31:0] BusW;
    input wire [31:0] BusA, BusB;
    input wire clk;

    wire [7:0] ex0MuxOut;
    wire [7:0] ex1MuxOut;
    wire [7:0] sALUOut;
    wire [7:0] exRoundOut;
    wire [7:0] expDiffCtrl;
    wire [22:0] muxAOut;
    wire [22:0] muxBOut;
    wire [22:0] bALUOut;
    wire [22:0] bALUMux;
    wire [22:0] muxARShiftOut;
    wire [22:0] bALUMuxOut;
    wire [22:0] fracRoundOut;

    // Control Hardware
    wire ex0MuxCtrl;
    wire ex1MuxCtrl;
    wire muxActrl;
    wire muxBctrl;
    wire [7:0] muxARshiftctrl;
    wire bALUMuxCtrl;
    wire bALUshiftctrl;
    wire exincdecctrl;
    wire roundingctrl;
    wire expMuxCtrl;

    wire signA;
    wire signB;

    wire [7:0] expA;
    wire [7:0] expB;

    wire [22:0] fracA;
    wire [22:0] fracB;

    assign signA = BusA[31];
    assign signB = BusB[31];

    assign expA = BusA[30:23];
    assign expB = BusB[30:23];

    assign fracA = BusA[22:0];
    assign fracB = BusB[22:0];

    // Control logic
    FPUAddController FPUAddController(
        .ex0MuxCtrl(ex0MuxCtrl), .ex1MuxCtrl(ex1MuxCtrl), .muxActrl(muxActrl), 
        .muxBctrl(muxBctrl), .muxARshiftctrl(muxARshiftctrl), .bALUMuxCtrl(bALUMuxCtrl), 
        .bALUshiftctrl(bALUshiftctrl), .exincdecctrl(exincdecctrl), .roundingctrl(roundingctrl), 
        .expMuxCtrl(expMuxCtrl), .expDiffCtrl(expDiffCtrl), .bALUOut(bALUOut), .fracRoundOut(fracRoundOut)
    );

    // Addition logic
    ALU_8b smallALU(
        .BusW(sALUOut), .BusA(expA), .BusB(expB), .ALUCtrl(4'b0110), .Clk(clk)
    );

    assign expdiffctrl = sALUOut; // Fix to not be negative

    Mux2to1_8b muxEx0(
        .out(ex0MuxOut), .in1(expA), .in2(expB), .ctrl(ex0MuxCtrl)
    );

    Mux2to1_8b muxEx1(
        .out(ex1MuxOut), .in1(ex0MuxOut), .in2(exRoundOut), .ctrl(ex1MuxCtrl)
    );

    // Increment/Decrement.

    Mux2to1_23b muxA(
        .out(muxAOut), .in1(fracA), .in2(fracB), .ctrl(muxActrl)
    );

    Mux2to1_23b muxB(
        .out(muxBOut), .in1(fracA), .in2(fracB), .ctrl(muxBctrl)
    );

    BitShifter rightShift(
        .out(muxARShiftOut), .in(muxAOut), .shift_value(muxARshiftctrl), .shift_dir(1'b1), .clk(clk)
    );

    ALU_23b bigALU(
        .BusW(bALUOut), .BusA(muxARShiftOut), .BusB(muxBOut), .ALUCtrl(4'b0010), .Clk(clk)
    );

    Mux2to1_23b MUxbALUOut(
        .out(bALUMuxOut), .in1(bALUOut), .in2(fracRoundOut), .ctrl(bALUMuxCtrl)
    );

    // Bit shifter here.
endmodule