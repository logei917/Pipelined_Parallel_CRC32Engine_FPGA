module crc_tb;

    // Declare inputs as regs and outputs as wires
    reg [31:0] data;
    reg [31:0] crcIn;
    wire [31:0] crcOut;

    // Instantiate the CRC module
    crc crc_instance (
        .crcIn(crcIn),
        .data(data),
        .crcOut(crcOut)
    );

    // Test vectors
    initial begin
        // Initialize the crcIn with 0xFFFFFFFF for CRC-32
        crcIn = 32'hFFFFFFFF;

        // Test case 1: arbitrary data input
        data = 32'h12345678;
        #10; // Wait for the output to settle
        $display("Data: %h, CRC Out: %h", data, crcOut);

        // Test case 2: another data input
        data = 32'h87654321;
        #10;
        $display("Data: %h, CRC Out: %h", data, crcOut);

        // Test case 3: all zeros
        data = 32'h00000000;
        #10;
        $display("Data: %h, CRC Out: %h", data, crcOut);

        // Test case 4: all ones
        data = 32'hFFFFFFFF;
        #10;
        $display("Data: %h, CRC Out: %h", data, crcOut);

        // Finish the simulation
        $stop;
    end

endmodule
