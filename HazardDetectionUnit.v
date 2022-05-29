`timescale 1 ns / 1 ps

module HazardDetectionUnit(PC_WriteEn, IFID_WriteEn, Stall_flush, IDEX_MemRead, IDEX_rd, IFID_rn, IFID_rm, IFID_rd);
    output reg PC_WriteEn, IFID_WriteEn, Stall_flush;
    input wire IDEX_MemRead;
    input wire [4:0] IFID_rm, IFID_rn, IFID_rd, IDEX_rd;

    always @(*)
    begin
        if(IDEX_MemRead && ((IDEX_rd == IFID_rn) || (IDEX_rd == IFID_rm)))
        begin
            PC_WriteEn = 1'b0;
            IFID_WriteEn = 1'b0;
            Stall_flush = 1'b1;
        end
        else
        begin
            PC_WriteEn = 1'b1;
            IFID_WriteEn = 1'b1;
            Stall_flush = 1'b0;
        end
    end
endmodule