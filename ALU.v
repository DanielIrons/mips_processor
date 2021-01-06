`timescale 1ns / 1ps

`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111
`define PassBM 4'b1000

module ALU(BusW, Zero, BusA, BusB, ALUCtrl, Clk);

    output  [63:0] BusW;
    output  Zero;
    input   [63:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    input   Clk;
    
    reg     [63:0] BusW;
    
    always @(BusA or BusB or ALUCtrl) begin
        // $display("ALUCtrl: %b BusA: %d BusB: %d, BusW: %h", ALUCtrl, BusA, BusB, BusW);
        case(ALUCtrl)
            `AND:
                BusW <= BusA & BusB;
            `OR: 
                BusW <= BusA | BusB;
            `ADD: begin
                BusW <= $signed(BusA) + $signed(BusB);
                end
            `SUB:
                BusW <= $signed(BusA) - $signed(BusB);
            `PassB:
                BusW <= {BusB, 16'b0};
          	`PassBM:
              	BusW <= BusB;
        endcase
    end

    assign Zero = (BusW == 64'b0) ? 1 : 0;
endmodule