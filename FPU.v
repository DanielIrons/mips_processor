`timescale 1ns / 1ps

`define ADD32   4'b0000
`define SUB32   4'b0001
`define MUL32   4'b0010
`define DIV32   4'b0011
`define ADD64   4'b0100
`define SUB64   4'b0101
`define MUL64   4'b0110
`define DIV64   4'b0111

module FPU(BusA, BusB, BusO, FPUCtrl)
    output [63:0] BusO;
    input [63:0] BusA, BusB;
    input[3:0] FPUCtrl;

    wire muxAout;
    wire muxBout;
    wire exmuxout;
    wire sALUout;
    wire bALUout;
    wire bALUmux;

    // Control hardware
    wire ex0muxctrl;
    wire muxActrl;
    wire muxBctrl;
    wire muxARshiftctrl;
    wire bALUctrl;
    wire bALUshiftctrl;
    wire ex1muxctrl;
    wire exincdecctrl;
    wire roundingctrl;

    always@(BusA or BusB or FPUCtrl)
        case(FPUCtrl)
            `ADD32: begin
                
            end
            `SUB32: 

            `MUL32:

            `DIV32:

        endcase

endmodule