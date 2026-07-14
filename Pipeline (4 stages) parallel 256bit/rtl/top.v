`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Top-level wrapper for 4-stage pipeline CRC-32C on AX7102
//
// Board: AX7102 (Artix-7 FPGA)
// Clock: 200 MHz differential on R4 (p) / T4 (n)
//
// Debug interfaces:
//   - VIO (4 probe_out / 1 probe_in)
//     * probe_out0[31:0]  -> crcIn
//     * probe_out1[255:0] -> data
//     * probe_out2        -> trigger / valid_in
//     * probe_out3        -> rst_n
//     * probe_in0[31:0]   <- crcOut
//   - ILA (3 probes)
//     * probe0[31:0]      <- crcOut
//     * probe1            <- valid_out   (used as ILA trigger)
//     * probe2            <- trigger     (valid_in, for observation)
//////////////////////////////////////////////////////////////////////////////////

module top (
    input clk_p,
    input clk_n
);

    //----------------------------------------------------------------------
    // Differential clock input
    //----------------------------------------------------------------------
    wire clk;

    IBUFDS #(
        .DIFF_TERM("TRUE"),
        .IOSTANDARD("LVDS_25")
    ) u_ibufds_clk (
        .I  (clk_p),
        .IB (clk_n),
        .O  (clk)
    );

    //----------------------------------------------------------------------
    // VIO / ILA interconnect
    //----------------------------------------------------------------------
    wire [31:0]  crcIn_vio;
    wire [255:0] data_vio;
    wire         trigger;      // VIO probe_out2 -> valid_in
    wire         rst_n_vio;    // VIO probe_out3 -> global reset
    wire [31:0]  crcOut;
    wire         valid_out;

    // VIO: interactive control via Vivado Hardware Manager
    vio_0 vio_inst (
        .clk       (clk),
        .probe_out0(crcIn_vio),   // 32 bit
        .probe_out1(data_vio),    // 256 bit
        .probe_out2(trigger),     // 1 bit -> valid_in
        .probe_out3(rst_n_vio),   // 1 bit -> rst_n
        .probe_in0 (crcOut)       // 32 bit
    );

    // ILA: capture crcOut, valid_out and trigger
    ila_0 ila_inst (
        .clk   (clk),
        .probe0(crcOut),          // 32 bit
        .probe1(valid_out),       // 1 bit -> used as ILA trigger
        .probe2(trigger)          // 1 bit -> valid_in observation
    );

    //----------------------------------------------------------------------
    // Pipeline CRC: 4-stage, latency = 4 cycles
    //----------------------------------------------------------------------
    crc32_parallel256_pipe u_crc (
        .clk      (clk),
        .rst_n    (rst_n_vio),
        .crcIn    (crcIn_vio),
        .data     (data_vio),
        .valid_in (trigger),
        .crcOut   (crcOut),
        .valid_out(valid_out)
    );

endmodule
