`timescale 1ns / 1ps

module SignExtender(BusImm, Imm26, Ctrl, Clk);
    output [63:0] BusImm;
    input [25:0] Imm26;
    input [2:0] Ctrl;
    input Clk;
    
    reg [63:0] BusImm;

    wire [1:0] shift;
    assign shift = Imm26[22:21];

    always@(Clk) begin
            // $display("Ctrl: %b BusImm: %b", Ctrl, BusImm);
            case(Ctrl)
                2'b00: // I
                    BusImm = {{53{Imm26[21]}}, Imm26[21:10]};
                2'b01: // D
                    BusImm = {{56{Imm26[20]}}, Imm26[19:12]};
                2'b10: // B
                    BusImm = {{39{Imm26[25]}}, Imm26[24:0]};
                2'b11: // CB
                    BusImm = {{45{Imm26[23]}}, Imm26[23:5]};
            	
               	3'b1xx:
                  begin
                      case(shift)
                            2'b00:
                                 BusImm = {48'b0, Imm26[20:5]};
                            2'b01:
                                 BusImm = {{32'b0, Imm26[20:5]}, 16'b0};
                            2'b10:
                                BusImm = {{16'b0, Imm26[20:5]}, 32'b0};
                            2'b11:
                                BusImm = {Imm26[20:5], 48'b0};
                      endcase
                  end
                default: 
                    BusImm = 64'b0;
            endcase
        end
endmodule