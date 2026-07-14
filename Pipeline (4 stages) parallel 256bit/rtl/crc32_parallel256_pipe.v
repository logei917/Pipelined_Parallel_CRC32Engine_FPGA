`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2026/06/05 15:30:05
// Design Name: 256-bit Parallel CRC-32C 4-Stage Pipeline (wrapper)
// Module Name: crc32_parallel256_pipe
//
// Description:
//   4-stage pipeline for 256-bit parallel CRC-32C (Castagnoli).
//   Each stage processes 64 bits using the crc32_parallel_64 sub-module.
//   Latency = 4 clock cycles.
//   Throughput = 1 x 256-bit result per clock cycle.
//
//   Data flow (MSB-first within each 64-bit chunk):
//     Stage1: crc1 = crc64(crcIn,      data[255:192])
//     Stage2: crc2 = crc64(crc1,       data[191:128])
//     Stage3: crc3 = crc64(crc2,       data[127:64] )
//     Stage4: crc4 = crc64(crc3,       data[63:0]   )
//////////////////////////////////////////////////////////////////////////////////

module crc32_parallel256_pipe(
    input              clk,
    input              rst_n,
    input      [31:0]  crcIn,
    input      [255:0] data,
    input              valid_in,
    output reg [31:0]  crcOut,
    output             valid_out
);

    //--------------------------------------------------------------------------
    // 1. Combinational slice of the 256-bit input into four 64-bit chunks
    //--------------------------------------------------------------------------
    // d3: most significant 64 bits (processed first in Stage1)
    wire [63:0] d3 = data[255:192];
    // d2: second 64-bit chunk (processed in Stage2)
    wire [63:0] d2 = data[191:128];
    // d1: third 64-bit chunk (processed in Stage3)
    wire [63:0] d1 = data[127:64];
    // d0: least significant 64 bits (processed last in Stage4)
    wire [63:0] d0 = data[63:0];

    //--------------------------------------------------------------------------
    // 2. Pipeline registers
    //--------------------------------------------------------------------------
    // Stage 0: input registration (no CRC computation yet)
    reg [31:0]  crc_s0;     // registered crcIn from upstream
    reg [63:0]  d3_s0;      // registered data[255:192] for Stage1
    reg [63:0]  d2_s0;      // registered data[191:128] for Stage2
    reg [63:0]  d1_s0;      // registered data[127:64]  for Stage3
    reg [63:0]  d0_s0;      // registered data[63:0]    for Stage4
    reg         valid_s0;   // registered valid flag

    // Stage 1: after first 64-bit CRC computation
    reg [31:0]  crc_s1;     // partial CRC after processing data[255:192]
    reg [63:0]  d2_s1;      // data[191:128] delayed to Stage2
    reg [63:0]  d1_s1;      // data[127:64]  delayed to Stage3
    reg [63:0]  d0_s1;      // data[63:0]    delayed to Stage4
    reg         valid_s1;   // valid flag delayed by 1 cycle

    // Stage 2: after second 64-bit CRC computation
    reg [31:0]  crc_s2;     // partial CRC after processing data[191:128]
    reg [63:0]  d1_s2;      // data[127:64]  delayed to Stage3
    reg [63:0]  d0_s2;      // data[63:0]    delayed to Stage4
    reg         valid_s2;   // valid flag delayed by 2 cycles

    // Stage 3: after third 64-bit CRC computation
    reg [31:0]  crc_s3;     // partial CRC after processing data[127:64]
    reg [63:0]  d0_s3;      // data[63:0] delayed to Stage4
    reg         valid_s3;   // valid flag delayed by 3 cycles

    // Stage 4: after final 64-bit CRC computation
//    reg [31:0]  crc_s4;     // final CRC output (drives crcOut)
    reg         valid_s4;   // final valid flag (drives valid_out)

    //--------------------------------------------------------------------------
    // 3. Stage 0: Input registration
    //    Latch all inputs on the rising edge of clk.
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_s0   <= 32'd0;
            d3_s0    <= 64'd0;
            d2_s0    <= 64'd0;
            d1_s0    <= 64'd0;
            d0_s0    <= 64'd0;
            valid_s0 <= 1'b0;
        end else begin
            crc_s0   <= crcIn;
            d3_s0    <= d3;
            d2_s0    <= d2;
            d1_s0    <= d1;
            d0_s0    <= d0;
            valid_s0 <= valid_in;
        end
    end

    //--------------------------------------------------------------------------
    // 4. Stage 1: Process data[255:192] (MSB 64 bits)
    //    Combinational: crc_s1_next = crc64(crc_s0, d3_s0)
    //    Registered:    crc_s1, d2_s1, d1_s1, d0_s1, valid_s1
    //--------------------------------------------------------------------------
    wire [31:0] crc_s1_next;
    crc32_parallel_64 u_crc_stage1 (
        .crcIn (crc_s0),
        .data  (d3_s0),
        .crcOut(crc_s1_next)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_s1   <= 32'd0;
            d2_s1    <= 64'd0;
            d1_s1    <= 64'd0;
            d0_s1    <= 64'd0;
            valid_s1 <= 1'b0;
        end else begin
            crc_s1   <= crc_s1_next;  // latch partial CRC result
            d2_s1    <= d2_s0;        // pass remaining data to next stage
            d1_s1    <= d1_s0;
            d0_s1    <= d0_s0;
            valid_s1 <= valid_s0;
        end
    end

    //--------------------------------------------------------------------------
    // 5. Stage 2: Process data[191:128]
    //    Combinational: crc_s2_next = crc64(crc_s1, d2_s1)
    //    Registered:    crc_s2, d1_s2, d0_s2, valid_s2
    //--------------------------------------------------------------------------
    wire [31:0] crc_s2_next;
    crc32_parallel_64 u_crc_stage2 (
        .crcIn (crc_s1),
        .data  (d2_s1),
        .crcOut(crc_s2_next)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_s2   <= 32'd0;
            d1_s2    <= 64'd0;
            d0_s2    <= 64'd0;
            valid_s2 <= 1'b0;
        end else begin
            crc_s2   <= crc_s2_next;
            d1_s2    <= d1_s1;        // pass remaining data to next stage
            d0_s2    <= d0_s1;
            valid_s2 <= valid_s1;
        end
    end

    //--------------------------------------------------------------------------
    // 6. Stage 3: Process data[127:64]
    //    Combinational: crc_s3_next = crc64(crc_s2, d1_s2)
    //    Registered:    crc_s3, d0_s3, valid_s3
    //--------------------------------------------------------------------------
    wire [31:0] crc_s3_next;
    crc32_parallel_64 u_crc_stage3 (
        .crcIn (crc_s2),
        .data  (d1_s2),
        .crcOut(crc_s3_next)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_s3   <= 32'd0;
            d0_s3    <= 64'd0;
            valid_s3 <= 1'b0;
        end else begin
            crc_s3   <= crc_s3_next;
            d0_s3    <= d0_s2;        // pass last chunk to final stage
            valid_s3 <= valid_s2;
        end
    end

    //--------------------------------------------------------------------------
    // 7. Stage 4: Process data[63:0] (LSB 64 bits)
    //    Combinational: crc_s4_next = crc64(crc_s3, d0_s3)
    //    Registered:    crc_s4 [abandoned], valid_s4
    //--------------------------------------------------------------------------
    wire [31:0] crc_s4_next;
    crc32_parallel_64 u_crc_stage4 (
        .crcIn (crc_s3),
        .data  (d0_s3),
        .crcOut(crc_s4_next)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crcOut   <= 32'd0;   // output reg drive here
            valid_s4 <= 1'b0;
        end else begin
            crcOut   <= crc_s4_next;  // latch final result here
            valid_s4 <= valid_s3;
        end
    end

    //--------------------------------------------------------------------------
    // 8. Output assignment [abandoned]
    //--------------------------------------------------------------------------
//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            crcOut <= 32'd0;
//        end else begin
//            crcOut <= crc_s4;
//        end
//    end

    assign valid_out = valid_s4;

endmodule
