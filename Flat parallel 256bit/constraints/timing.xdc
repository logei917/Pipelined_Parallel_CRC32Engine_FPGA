################################################################################
# timing.xdc  --  Flat combinational CRC with external output at 200 MHz
################################################################################

# Configuration bank voltage settings
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# 200 MHz single-ended clock on AX7102 (R4)
create_clock -name clk -period 5.000 -waveform {0.000 2.500} [get_ports clk]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]

# Route debug hub clock from the global clock buffer
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]

################################################################################
# External CRC output constraints
#
# The flat combinational CRC has its output driven to external pins.  The
# set_output_delay models the downstream setup/hold window (PCB trace + receiver
# setup/hold).  This makes the complete path:
#   VIO output register -> u_crc logic -> OBUF -> package pin
# fail timing at 200 MHz, demonstrating the need for the pipelined architecture.
################################################################################

set_output_delay -clock clk -max 2.000 [get_ports crc_out[*]]
set_output_delay -clock clk -min -1.000 [get_ports crc_out[*]]

# Example pin assignments for xc7a100t-fgg484 BANK 16 GPIOs.
# These are placeholders -- change them to match the AX7102 expansion connector
# or any available GPIOs on your board if you plan to actually drive them.
set_property -dict {PACKAGE_PIN AA1  IOSTANDARD LVCMOS33} [get_ports {crc_out[0]}]
set_property -dict {PACKAGE_PIN AB1  IOSTANDARD LVCMOS33} [get_ports {crc_out[1]}]
set_property -dict {PACKAGE_PIN AA2  IOSTANDARD LVCMOS33} [get_ports {crc_out[2]}]
set_property -dict {PACKAGE_PIN AB2  IOSTANDARD LVCMOS33} [get_ports {crc_out[3]}]
set_property -dict {PACKAGE_PIN AA3  IOSTANDARD LVCMOS33} [get_ports {crc_out[4]}]
set_property -dict {PACKAGE_PIN AB3  IOSTANDARD LVCMOS33} [get_ports {crc_out[5]}]
set_property -dict {PACKAGE_PIN AA4  IOSTANDARD LVCMOS33} [get_ports {crc_out[6]}]
set_property -dict {PACKAGE_PIN AB4  IOSTANDARD LVCMOS33} [get_ports {crc_out[7]}]
set_property -dict {PACKAGE_PIN AA5  IOSTANDARD LVCMOS33} [get_ports {crc_out[8]}]
set_property -dict {PACKAGE_PIN AB5  IOSTANDARD LVCMOS33} [get_ports {crc_out[9]}]
set_property -dict {PACKAGE_PIN AA6  IOSTANDARD LVCMOS33} [get_ports {crc_out[10]}]
set_property -dict {PACKAGE_PIN AB6  IOSTANDARD LVCMOS33} [get_ports {crc_out[11]}]
set_property -dict {PACKAGE_PIN AA7  IOSTANDARD LVCMOS33} [get_ports {crc_out[12]}]
set_property -dict {PACKAGE_PIN AB7  IOSTANDARD LVCMOS33} [get_ports {crc_out[13]}]
set_property -dict {PACKAGE_PIN AA8  IOSTANDARD LVCMOS33} [get_ports {crc_out[14]}]
set_property -dict {PACKAGE_PIN AB8  IOSTANDARD LVCMOS33} [get_ports {crc_out[15]}]
set_property -dict {PACKAGE_PIN AA9  IOSTANDARD LVCMOS33} [get_ports {crc_out[16]}]
set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVCMOS33} [get_ports {crc_out[17]}]
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS33} [get_ports {crc_out[18]}]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {crc_out[19]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {crc_out[20]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {crc_out[21]}]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS33} [get_ports {crc_out[22]}]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS33} [get_ports {crc_out[23]}]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33} [get_ports {crc_out[24]}]
set_property -dict {PACKAGE_PIN AB13 IOSTANDARD LVCMOS33} [get_ports {crc_out[25]}]
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS33} [get_ports {crc_out[26]}]
set_property -dict {PACKAGE_PIN AB14 IOSTANDARD LVCMOS33} [get_ports {crc_out[27]}]
set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS33} [get_ports {crc_out[28]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS33} [get_ports {crc_out[29]}]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33} [get_ports {crc_out[30]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports {crc_out[31]}]
