module ForwardingUnit(ForwardA, ForwardB, Branching, EXMEM_RegWrite, MEMWB_RegWrite, EXMEMrd, MEMWBrd, IDEX_rm, IDEX_rn);
    output reg [1:0] ForwardA, ForwardB;
    input Branching, EXMEM_RegWrite, MEMWB_RegWrite;
    input [4:0] EXMEMrd, MEMWBrd, IDEX_rm, IDEX_rn;

    always@(*) begin
        ForwardA[0] = ~Branching && (~((EXMEM_RegWrite === 1) && (EXMEMrd === IDEX_rm)) && ((MEMWB_RegWrite === 1) && (MEMWBrd === IDEX_rm)));
    
        ForwardA[1] = ~Branching && ((EXMEM_RegWrite === 1) && (EXMEMrd === IDEX_rm));

        ForwardB[0] = ~Branching && ~((EXMEM_RegWrite === 1) && (EXMEMrd === IDEX_rn)) && ((MEMWB_RegWrite === 1) && (MEMWBrd === IDEX_rn));

        ForwardB[1] = ~Branching && ((EXMEM_RegWrite === 1) && (EXMEMrd === IDEX_rn));
    end
endmodule