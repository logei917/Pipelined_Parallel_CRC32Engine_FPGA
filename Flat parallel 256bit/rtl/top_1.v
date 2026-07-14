//////////////////////////////////////////////////////////////////////////////////
// Top-level wrapper for FLAT (fully-combinational) 256-bit CRC-32C.
//
// This version adds an external 32-bit output "crc_out" so that Vivado must
// time the complete path: debug registers -> flat CRC logic -> OBUF -> pin.
// The external output delay is what makes the 200 MHz constraint fail,
// demonstrating why the pipelined architecture is required.
//
// Interfaces:
//   - clk: board clock (200 MHz single-ended for this rollback case)
//   - crc_out[31:0]: external CRC output pins
//   - VIO: virtual input/output for interactive debugging
//     * probe_out0[31:0]  -> crcIn
//     * probe_out1[255:0] -> data
//     * probe_out2        -> trigger (unused for combinational CRC, fed to ILA)
//     * probe_in0[31:0]   <- crcOut
//   - ILA: logic analyzer capturing crcOut and trigger
//////////////////////////////////////////////////////////////////////////////////

module top (
    input clk,
    output [31:0] crc_out
);

    wire [31:0]  crcIn_vio;
    wire [255:0] data_vio;
    wire         trigger;
    wire [31:0]  crcOut;

    // VIO: interactive control via Vivado Hardware Manager
    vio_0 vio_inst (
        .clk(clk),
        .probe_out0(crcIn_vio),   // 32 bit
        .probe_out1(data_vio),    // 256 bit
        .probe_out2(trigger),     // 1 bit
        .probe_in0(crcOut)        // 32 bit
    );

    // ILA: capture crcOut and trigger for waveform view
    ila_0 ila_inst (
        .clk(clk),
        .probe0(crcOut),          // 32 bit
        .probe1(trigger)          // 1 bit
    );

    // Flat combinational CRC: single-cycle, large combinational path
    crc32_parallel_256 u_crc (
        .crcIn(crcIn_vio),
        .data(data_vio),
        .crcOut(crcOut)
    );

    // Drive external pins: this creates the OBUF + output-delay timing path
    // that causes the 200 MHz constraint to fail.
    assign crc_out = crcOut;

endmodule
