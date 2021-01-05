`timescale 1ns / 1ps

`define AND    4'b0000
`define OR     4'b0001
`define ADD    4'b0010
`define SUB    4'b0110
`define PassB  4'b0111
`define PassBM 4'b1000


module ALU_8b(BusW, BusA, BusB, ALUCtrl, Clk);

    output reg [7:0] BusW;
    output Zero;
    input [7:0] BusA, BusB;
    input [3:0] ALUCtrl;
    input Clk;
    
    
    always @(Clk) begin
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
                BusW <= BusB;
          	`PassBM:
              	BusW <= BusB;
        endcase
    end
endmodule