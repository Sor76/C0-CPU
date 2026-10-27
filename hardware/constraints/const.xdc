set_property -dict {PACKAGE_PIN H11 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name sys_clk [get_ports clk]

# # set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports rst_n]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports rst_n]

# LCD
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[0]}]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[1]}]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[2]}]
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[3]}]
set_property -dict {PACKAGE_PIN P13 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[4]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[5]}]
set_property -dict {PACKAGE_PIN M12 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[6]}]
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS33} [get_ports {lcd_write_data[7]}]
set_property -dict {PACKAGE_PIN M5 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports lcd_e]

# Direct Button
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[0] }]; #Button-top
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[1] }]; #Button-bottom
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[2] }]; #Button-left
set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[3] }]; #Button-right
set_property -dict { PACKAGE_PIN J12 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[4] }]; #Button-center

