`timescale 1 ns / 1 ps

module ForwardingUnit(ForwardA, ForwardB, EXMEM_RegWrite, MEMWB_RegWrite, EXMEM_WriteRegister, MEMWB_WriteRegister, IDEX_rm, IDEX_rn, Clk);
    output wire [1:0] ForwardA, ForwardB;
    input EXMEM_RegWrite, MEMWB_RegWrite, Clk;
    input [4:0] EXMEM_WriteRegister, MEMWB_WriteRegister, IDEX_rm, IDEX_rn;

    // a = 1 if ( EXMEM_WriteRegister != 0 )
    or orMEM_WriteReg(a, EXMEM_WriteRegister[4], EXMEM_WriteRegister[3], EXMEM_WriteRegister[2], EXMEM_WriteRegister[1], EXMEM_WriteRegister[0]);
    // b = 1 if EXMEM_WReg == IDEX_rm
    CompareAddress CompMEM_WriteReg_EXrs(b, EXMEM_WriteRegister, IDEX_rm);
    // x = 1 if ((EXMEM_RegWrite == 1) && (EXMEM_WriteRegister != 0) && (EXMEM_WriteRegister == EX_rm))
    and andx(x, EXMEM_RegWrite, a, b);
    // c = 1 if ( WB_WriteRegister != 0 )
    or orWB_WriteReg(c, MEMWB_WriteRegister[4], MEMWB_WriteRegister[3], MEMWB_WriteRegister[2], MEMWB_WriteRegister[1], MEMWB_WriteRegister[0]);
    // d = 1 if ()
    CompareAddress CompWB_WriteReg_EXrs(d, MEMWB_WriteRegister, IDEX_rm);
    // y = 1 if ((WB_RegWrite==1) && (WB_WriteRegister != 0) && (WB_WriteRegister == EX_rm))
    and andy(y, MEMWB_RegWrite, c, d);

    // ForwardA[1] = x; and ForwardA[0] = (NOT x). y ;
    assign ForwardA[1] = x;
    not notxgate(notx,x);
    and NOTxANDy(ForwardA[0],notx,y);


    // ForwardB 
    CompareAddress CompMEM_WriteReg_EXrt(b1, EXMEM_WriteRegister, IDEX_rn);

    CompareAddress CompWB_WriteReg_EXrt(d1, MEMWB_WriteRegister, IDEX_rn);

    and #(50) andx1(x1, EXMEM_RegWrite, a, b1);

    and #(50) andy1(y1, MEMWB_RegWrite, c, d1);

    assign ForwardB[1] = x1;
    not #(50) notx1gate(notx1, x1);
    and #(50) NOTx1ANDy1(ForwardB[0], notx1, y1);
endmodule

module CompareAddress(out, in1, in2);
    output reg out;
    input wire [4:0] in1;
    input wire [4:0] in2;
    // wire intermediate;
    // wire not_intermediate;

    // xor test(intermediate, in1, in2);
    // not flip_intermediate(not_intermediate, intermediate);
    // assign out = not_intermediate;

    always@(*) begin
        // $display("comparing: in1: %b in2: %b, out: %b", in1, in2, out);
        if(in1-in2 == 0)
            out <= 1;
        else
            out <= 0;
    end
endmodule