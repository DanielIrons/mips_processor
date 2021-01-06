module ForwardingUnit(ForwardA, ForwardB, EXMEM_RegWrite, MEMWB_RegWrite, EXMEM_WriteRegister, MEMWB_WriteRegister, IDEX_rm, IDEX_rn, Clk);
    output reg [1:0] ForwardA, ForwardB;
    input EXMEM_RegWrite, MEMWB_RegWrite, Clk;
    input [4:0] EXMEM_WriteRegister, MEMWB_WriteRegister, IDEX_rm, IDEX_rn;

    always@(EXMEM_RegWrite or MEMWB_RegWrite or EXMEM_WriteRegister or MEMWB_WriteRegister or IDEX_rm or IDEX_rn or posedge Clk) begin

        ForwardA[0] = (~((EXMEM_RegWrite == 1) && (EXMEM_WriteRegister == IDEX_rm)) && ((MEMWB_RegWrite==1) && (MEMWB_WriteRegister == IDEX_rm)));
    
        ForwardA[1] = ((EXMEM_RegWrite == 1) && (EXMEM_WriteRegister == IDEX_rm));

        ForwardB[0] = ~((EXMEM_RegWrite == 1) && (EXMEM_WriteRegister == IDEX_rn)) && ((MEMWB_RegWrite==1) && (MEMWB_WriteRegister == IDEX_rn));

        ForwardB[1] = ((EXMEM_RegWrite == 1) && (EXMEM_WriteRegister == IDEX_rn));
    end
endmodule