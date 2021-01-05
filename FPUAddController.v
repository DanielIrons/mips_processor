`timescale 1ns / 1ps

module FPUAddController(
    ex0MuxCtrl, ex1MuxCtrl, muxActrl,
    muxBctrl, muxARshiftctrl, bALUMuxCtrl,
    bALUshiftctrl, exincdecctrl, roundingctrl,
    expMuxCtrl, expDiffCtrl, bALUOut, fracRoundOut
    );
    output ex0MuxCtrl;
    output ex1MuxCtrl;
    output muxActrl;
    output muxBctrl;
    output bALUMuxCtrl;
    output bALUshiftctrl;
    output exincdecctrl;
    output roundingctrl;
    output expMuxCtrl;
    output [7:0] muxARshiftctrl;
    input [7:0] expDiffCtrl;
    input [22:0] bALUOut;
    input [22:0] fracRoundOut;


endmodule