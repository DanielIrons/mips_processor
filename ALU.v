`timescale 1ns / 1ps

`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111
`define PassBM 4'b1000

module ALU(BusW, Zero, BusA, BusB, ALUCtrl);

    output  reg [63:0] BusW;
    output  reg Zero;
    input   [63:0] BusA, BusB;
    input   [3:0] ALUCtrl;
    
    always @(*) begin
        case(ALUCtrl)
            `AND:
                BusW <= BusA & BusB;
            `OR: 
                BusW <= BusA | BusB;
            `ADD:
                BusW <= $signed(BusA) + $signed(BusB);
            `SUB:
                BusW <= $signed(BusA) - $signed(BusB);
            `PassB:
                BusW <= {BusB, 16'b0};
          	`PassBM:
              	BusW <= BusB;
        endcase
        Zero <= (BusW == 64'b0) ? 1 : 0;
    end
endmodule