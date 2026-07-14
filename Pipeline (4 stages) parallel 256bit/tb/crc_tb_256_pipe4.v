`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for crc32_parallel256_pipe_top (4-stage pipeline)
//
// Strategy:
//   - Feed 4 classic test vectors back-to-back (1 per clock cycle)
//     to verify continuous pipeline operation.
//   - Print the output every cycle so the user can cross-check
//     against the reference in the waveform viewer.
//   - valid_out goes high 4 cycles after the first valid_in.
//////////////////////////////////////////////////////////////////////////////////

module crc_tb_256_pipe4;

    //--------------------------------------------------------------------------
    // Signals
    //--------------------------------------------------------------------------
    reg          clk;
    reg          rst_n;
    reg  [31:0]  crcIn;
    reg  [255:0] data;
    reg          valid_in;

    wire [31:0]  crcOut;
    wire         valid_out;

    //--------------------------------------------------------------------------
    // DUT instantiation
    //--------------------------------------------------------------------------
    crc32_parallel256_pipe u_dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .crcIn    (crcIn),
        .data     (data),
        .valid_in (valid_in),
        .crcOut   (crcOut),
        .valid_out(valid_out)
    );

    //--------------------------------------------------------------------------
    // Clock: 200 MHz
    //--------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #2.5 clk = ~clk;
    end

    //--------------------------------------------------------------------------
    // Display header
    //--------------------------------------------------------------------------
    initial begin
        $display("============================================================");
        $display(" CRC-32C 256-bit 4-Stage Pipeline Testbench");
        $display(" Format: crc=8-digit-hex, data=64-digit-hex");
        $display("============================================================");
        $display(" Cycle | valid_in | crcIn    | data");
        $display("       | valid_out| crcOut   |");
        $display("------------------------------------------------------------");
    end

    //--------------------------------------------------------------------------
    // Monitor: print output on every rising edge
    //--------------------------------------------------------------------------
    reg [31:0] cycle_cnt;
    always @(posedge clk) begin
        #1;
        $display(" %5d | in=%b out=%b | crcIn=%08X crcOut=%08X",
                 cycle_cnt, valid_in, valid_out, crcIn, crcOut);
        cycle_cnt <= cycle_cnt + 1;
    end

    //--------------------------------------------------------------------------
    // Stimulus: apply 4 test vectors on consecutive cycles
    //--------------------------------------------------------------------------
    initial begin
        // Init
        cycle_cnt = 0;
        rst_n     = 1'b0;
        crcIn     = 32'h0;
        data      = 256'h0;
        valid_in  = 1'b0;

        // Reset for 25 ns
        repeat(5) @(posedge clk);
        #1 rst_n = 1'b1;

        // Cycle 0: Test vector 1 (all-zero data)
        @(posedge clk);
        #1;
        crcIn    = 32'hFFFFFFFF;
        data     = 256'h0000000000000000000000000000000000000000000000000000000000000000;
        valid_in = 1'b1;

        // Cycle 1: Test vector 2 (mixed pattern)
        @(posedge clk);
        #1;
        crcIn    = 32'hFFFFFFFF;
        data     = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;

        // Cycle 2: Test vector 3 (all-ones data)
        @(posedge clk);
        #1;
        crcIn    = 32'hFFFFFFFF;
        data     = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        // Cycle 3: Test vector 4 (zero init CRC)
        @(posedge clk);
        #1;
        crcIn    = 32'h00000000;
        data     = 256'hAABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899;

        // Cycle 4~7: idle (let pipeline drain while still clocking)
        repeat(4) begin
            @(posedge clk);
            #1;
            valid_in = 1'b0;
            crcIn    = 32'h0;
            data     = 256'h0;
        end

        $display("============================================================");
        $stop;
    end

endmodule
