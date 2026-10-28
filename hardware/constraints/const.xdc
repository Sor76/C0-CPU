set_property -dict {PACKAGE_PIN H11 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name sys_clk [get_ports clk]

# # set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports rst_n]
# set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports rst_n]

# VGA
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { vga_x[0] }];    # J5 pin5
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { vga_x[1] }];    # J5 pin6
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 } [get_ports { vga_x[2] }];    # J5 pin7
set_property -dict { PACKAGE_PIN H13 IOSTANDARD LVCMOS33 } [get_ports { vga_x[3] }];    # J5 pin8
set_property -dict { PACKAGE_PIN F11 IOSTANDARD LVCMOS33 } [get_ports { vga_x[4] }];    # J5 pin9
set_property -dict { PACKAGE_PIN G11 IOSTANDARD LVCMOS33 } [get_ports { vga_x[5] }];    # J5 pin10
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports { vga_x[6] }];    # J5 pin11
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { vga_x[7] }];    # J5 pin12
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS33 } [get_ports { vga_x[8] }];    # J5 pin13
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 } [get_ports { vga_y[0] }];    # J5 pin14
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { vga_y[1] }];    # J5 pin15
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports { vga_y[2] }];    # J5 pin16
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports { vga_y[3] }];    # J5 pin17
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports { vga_y[4] }];    # J5 pin18
set_property -dict { PACKAGE_PIN E12 IOSTANDARD LVCMOS33 } [get_ports { vga_y[5] }];    # J5 pin19
set_property -dict { PACKAGE_PIN F12 IOSTANDARD LVCMOS33 } [get_ports { vga_y[6] }];    # J5 pin20

# set_property -dict { PACKAGE_PIN P5  IOSTANDARD LVCMOS33 } [get_ports { vga_y[5] }];  # lcd_e
# set_property -dict { PACKAGE_PIN M5  IOSTANDARD LVCMOS33 } [get_ports { vga_y[6] }];  # lcd_rs
set_property -dict { PACKAGE_PIN M4  IOSTANDARD LVCMOS33 } [get_ports { vga_y[7] }];    # lcd data[0], led[7]
set_property -dict { PACKAGE_PIN L5  IOSTANDARD LVCMOS33 } [get_ports { vga_rgb[0] }];  # lcd data[1], led[6]
set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVCMOS33 } [get_ports { vga_rgb[1] }];  # lcd data[2], led[5]
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { vga_rgb[2] }];  # lcd data[3], led[4]
set_property -dict { PACKAGE_PIN P13 IOSTANDARD LVCMOS33 } [get_ports { vga_rgb[3] }];  # lcd data[4], led[3]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { vga_rgb[4] }];  # lcd data[5], led[2]
set_property -dict { PACKAGE_PIN M12 IOSTANDARD LVCMOS33 } [get_ports { vga_parity }];  # lcd D6, led[1]
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS33 } [get_ports { vga_strobe }];  # lcd D7, led[0]
# set_property -dict { PACKAGE_PIN M12 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { bus_d[22] }];  # lcd data[6], led[1]

# Direct Button
# set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[0] }]; #Button-top
# set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[1] }]; #Button-bottom
# set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[2] }]; #Button-left
# set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[3] }]; #Button-right
# set_property -dict { PACKAGE_PIN J12 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { direct_button_in[4] }]; #Button-center
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { direct_button_in[0] }]; #Button-top
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports { direct_button_in[1] }]; #Button-bottom
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { direct_button_in[2] }]; #Button-left
set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS33 } [get_ports { direct_button_in[3] }]; #Button-right
set_property -dict { PACKAGE_PIN J12 IOSTANDARD LVCMOS33 } [get_ports { direct_button_in[4] }]; #Button-center

