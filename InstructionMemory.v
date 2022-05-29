`timescale 1ns / 1ps

module InstructionMemory(Data, Address);
   parameter T_rd = 20;
   parameter MemSize = 40;
   
   output [31:0] Data;
   input [63:0]  Address;
   reg [31:0]    Data;
   
   always @ (Address) begin
		case(Address)
			// 64'h000: Data = 32'hD2E24689; // MOVZ #3 1234 -> X9
			// 64'h004: Data = 32'hD2CACF0A; // MOVZ #2 5678 -> X10
			// 64'h008: Data = 32'h8B0A0129; // ADD X9, X10, X9
			// 64'h00c: Data = 32'hD2B3578A; // MOVZ #1 9abc-> X10
			// 64'h010: Data = 32'h8B0A0129; // ADD X9, X10, X9
			// 64'h014: Data = 32'hD29BDE0A; // MOVZ #0 def0
			// 64'h018: Data = 32'h8B0A0129; // ADD X9, X10, X9
			// 64'h01c: Data = 32'hF80283E9; // STUR X9 [XZR, 0x28]
			// 64'h020: Data = 32'hF84283EA; // LDUR X10 [XZR, 0x28]

			63'h000: Data = 32'h910003E1; // ADDI #0 X31 -> X1
			63'h004: Data = 32'h910007E2; // ADDI #1 X31 -> X2
			63'h008: Data = 32'h910003E3; // ADDI #0 X31 -> X3
			63'h00c: Data = 32'h8B020021; // ADD X2, X1 -> X1
			63'h010: Data = 32'h8B020022; // ADD X2, X1 -> X2
			63'h014: Data = 32'hB4800043; // CBZ X3 -0x010

        	default: Data = 32'hXXXXXXXX;
    	endcase
	end
endmodule
