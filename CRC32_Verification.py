from crc import Calculator, Configuration
import sys


def calc_crc32c(crc_in, data_hex):
    """
    crc_in: 32-bit init value (e.g. 0xFFFFFFFF)
    data_hex: 256-bit data as hex string (64 chars) or any even-length hex string
    """
    data_bytes = bytes.fromhex(data_hex)
    cfg = Configuration(
        width=32,
        polynomial=0x1EDC6F41,
        init_value=crc_in & 0xFFFFFFFF,
        reverse_input=False,
        reverse_output=False,
    )
    calc = Calculator(cfg, optimized=True)
    return calc.checksum(data_bytes)


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        crc_in = int(sys.argv[1], 16)
        data_hex = sys.argv[2]
        result = calc_crc32c(crc_in, data_hex)
        print(f"Test - crcIn: {crc_in:08X}, data: {data_hex}, CRC Out: {result:08X}")
    else:
        print("=== CRC32-Castagnoli Reference (aligned with crc_tb_256.v) ===")
        test_cases = [
            ("ffffffff", "0000000000000000000000000000000000000000000000000000000000000000"),
            ("ffffffff", "123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0"),
            ("ffffffff", "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"),
            ("00000000", "AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899"),
        ]
        for crc_in_hex, data_hex in test_cases:
            crc_in = int(crc_in_hex, 16)
            result = calc_crc32c(crc_in, data_hex)
            print(f"Test - crcIn: {crc_in_hex}, data: {data_hex}, CRC Out: {result:08X}")
