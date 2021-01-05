`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module ProcTest_v;
    task passTest;
        input [63:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;
        inout [7:0] 	  passed;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    task allPassed;
        input [7:0] passed;
        input [7:0] numTests;

        if(passed == numTests) $display ("All tests passed");
        else $display("Some tests failed: %d of %d passed", passed, numTests);
    endtask

    // Inputs
    reg        CLK;
    reg [7:0]  passed;
    reg [31:0] BusA, BusB;
    reg numTests, currentTestNum;

    // Outputs
    wire [31:0] BusW;

    // Instantiate the Unit Under Test (UUT)
    FPU_add uut (
        .BusA(BusA),
        .BusB(BusB),
        .BusW(BusW),
        .clk(CLK)
    );

    initial begin
        // Initialize Inputs
        passed = 0;
        currentTestNum = 0;
        numTests = 1;

        // Wait for global reset
        #(1 * `ClockPeriod);

        // Program 1
        #(1 * `ClockPeriod);

        while (currentTestNum >= numTests)
          begin
            #(1 * `ClockPeriod);
            currentTestNum = currentTestNum + 1;
            // $display("CurrentPC: %h, WB_data: %h, instruction: %h, reg instruction: %h", currentPC, WB_data, instruction, first_instruction);
          end
        #(1 * `ClockPeriod);	// One more cycle to load the pass code from the DataMemory.

        // Done
        // allPassed(passed, 1);   // Be sure to change the one to match the number of tests you add.
        $finish;
    end

    initial begin
        CLK = 0;
    end

    // The following is correct if clock starts at LOW level at StartTime //
    always begin
        #`HalfClockPeriod CLK = ~CLK;
        #`HalfClockPeriod CLK = ~CLK;
    end
endmodule