module crc_tb_256;

    // Declare inputs as regs and outputs as wires
    reg [31:0]  crcIn;
    reg [255:0] data;
    wire [31:0] crcOut;

    // Instantiate the 256-bit parallel CRC module
    crc32_parallel_256 crc_instance (
        .crcIn(crcIn),
        .data(data),
        .crcOut(crcOut)
    );

    // Test vectors
    initial begin
        // Test case 1: all zeros data, init CRC
        crcIn = 32'hFFFFFFFF;
        data  = 256'h0000000000000000000000000000000000000000000000000000000000000000;
        #10;
        $display("Test1 - crcIn: %h, data: %h, CRC Out: %h", crcIn, data, crcOut);

        // Test case 2: arbitrary 256-bit data
        crcIn = 32'hFFFFFFFF;
        data  = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        #10;
        $display("Test2 - crcIn: %h, data: %h, CRC Out: %h", crcIn, data, crcOut);

        // Test case 3: all ones data
        crcIn = 32'hFFFFFFFF;
        data  = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10;
        $display("Test3 - crcIn: %h, data: %h, CRC Out: %h", crcIn, data, crcOut);

        // Test case 4: zero init CRC with mixed data
        crcIn = 32'h00000000;
        data  = 256'hAABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899;
        #10;
        $display("Test4 - crcIn: %h, data: %h, CRC Out: %h", crcIn, data, crcOut);

        // Finish the simulation
        $stop;
    end

endmodule