# bank voltage
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# 2. 200 MHz differential_clk
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVDS_25} [get_ports clk_p]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVDS_25} [get_ports clk_n]       
set_property DIFF_TERM TRUE [get_ports clk_p]               

create_clock -period 5.000 -name sys_clk -waveform {0.000 2.500} [get_ports clk_p]