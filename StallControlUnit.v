`timescale 1 ns / 1 ps

module StallControlUnit(PC_WriteEn, IFID_WriteEn, Stall_flush, IDEX_MemRead, IDEX_rd, IFID_rn, IFID_rm, IFID_rd);
    output reg PC_WriteEn, IFID_WriteEn, Stall_flush;
    input wire IDEX_MemRead, IFID_rm, IFID_rn, IFID_rd, IDEX_rd;

    always @(IDEX_MemRead or IDEX_rd or IFID_rm or IFID_rn)
    begin
        // if ((IDEX_MemRead == 1) && ((IDEX_rd == IFID_rn) || ((IDEX_rd == IFID_rd) && (IFID_Op != 6'b001110) && (IFID_Op != 6'b100011))))
        if(IDEX_MemRead && ((IDEX_rd == IFID_rn) || (IDEX_rd == IFID_rm)))
        begin
            PC_WriteEn = 1'b0;
            IFID_WriteEn = 1'b0;
            Stall_flush = 1'b1;
            $display("STALL");
        end
        else
        begin
            PC_WriteEn = 1'b1;
            IFID_WriteEn = 1'b1;
            Stall_flush = 1'b0;
        end
    end
endmodule