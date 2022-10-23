# GTP clock 125MHz
set_property PACKAGE_PIN D6 [get_ports gtrefclk_p]
set_property PACKAGE_PIN D5 [get_ports gtrefclk_n]

create_clock -period 8.000 -name gtref_clk -waveform {0.000 4.000} [get_nets gtref_clk]
create_clock -period 5.000 -name ref_clk -waveform {0.000 2.500} [get_nets ref_clk]
create_clock -period 8.000 -name core_clk -waveform {0.000 4.000} [get_nets core_clk]

# Reset Button (KEY1)
set_property PACKAGE_PIN J13 [get_ports RST]
set_property IOSTANDARD LVCMOS33 [get_ports RST]
set_false_path -from [get_ports RST]

# SFP+ 0
set_property PACKAGE_PIN D9 [get_ports {sfp_tx_disable[0]}]
set_property PACKAGE_PIN G3 [get_ports {sfp_rx_n[0]}]
set_property PACKAGE_PIN G4 [get_ports {sfp_rx_p[0]}]
set_property PACKAGE_PIN F1 [get_ports {sfp_tx_n[0]}]
set_property PACKAGE_PIN F2 [get_ports {sfp_tx_p[0]}]

# SFP+ 1
set_property PACKAGE_PIN D11 [get_ports {sfp_tx_disable[1]}]
set_property PACKAGE_PIN E3 [get_ports {sfp_rx_n[1]}]
set_property PACKAGE_PIN E4 [get_ports {sfp_rx_p[1]}]
set_property PACKAGE_PIN D1 [get_ports {sfp_tx_n[1]}]
set_property PACKAGE_PIN D2 [get_ports {sfp_tx_p[1]}]

# SFP+ 2
set_property PACKAGE_PIN C9 [get_ports {sfp_tx_disable[2]}]
set_property PACKAGE_PIN C3 [get_ports {sfp_rx_n[2]}]
set_property PACKAGE_PIN C4 [get_ports {sfp_rx_p[2]}]
set_property PACKAGE_PIN B1 [get_ports {sfp_tx_n[2]}]
set_property PACKAGE_PIN B2 [get_ports {sfp_tx_p[2]}]

# SFP+ 3
set_property PACKAGE_PIN D10 [get_ports {sfp_tx_disable[3]}]
set_property PACKAGE_PIN B5 [get_ports {sfp_rx_n[3]}]
set_property PACKAGE_PIN B6 [get_ports {sfp_rx_p[3]}]
set_property PACKAGE_PIN A3 [get_ports {sfp_tx_n[3]}]
set_property PACKAGE_PIN A4 [get_ports {sfp_tx_p[3]}]

# SFP+ RS
set_property PACKAGE_PIN D8 [get_ports {sfp_rs[0]}]
set_property PACKAGE_PIN E11 [get_ports {sfp_rs[1]}]
set_property PACKAGE_PIN C14 [get_ports {sfp_rs[2]}]
set_property PACKAGE_PIN C13 [get_ports {sfp_rs[3]}]
set_property PACKAGE_PIN B11 [get_ports {sfp_rs[4]}]
set_property PACKAGE_PIN B12 [get_ports {sfp_rs[5]}]
set_property PACKAGE_PIN E10 [get_ports {sfp_rs[6]}]
set_property PACKAGE_PIN B9 [get_ports {sfp_rs[7]}]

# SFP+ Port LEDs
set_property PACKAGE_PIN J11 [get_ports {sfp_led[0]}]
set_property PACKAGE_PIN J10 [get_ports {sfp_led[1]}]
set_property PACKAGE_PIN H14 [get_ports {sfp_led[2]}]
set_property PACKAGE_PIN G14 [get_ports {sfp_led[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {sfp_tx_disable[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rs[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_led[*]}]

# ETH1 RGMII
set_property PACKAGE_PIN G11 [get_ports rgmii1_rxc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_rxc]
set_property PACKAGE_PIN G12 [get_ports rgmii1_rx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_rx_ctl]
set_property PACKAGE_PIN H12 [get_ports {rgmii1_rxd[0]}]
set_property PACKAGE_PIN H11 [get_ports {rgmii1_rxd[1]}]
set_property PACKAGE_PIN F14 [get_ports {rgmii1_rxd[2]}]
set_property PACKAGE_PIN F13 [get_ports {rgmii1_rxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii1_rxd[*]}]

set_property PACKAGE_PIN G10 [get_ports rgmii1_txc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_txc]
set_property PACKAGE_PIN F12 [get_ports rgmii1_tx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_tx_ctl]
set_property PACKAGE_PIN G9 [get_ports {rgmii1_txd[0]}]
set_property PACKAGE_PIN F9 [get_ports {rgmii1_txd[1]}]
set_property PACKAGE_PIN F8 [get_ports {rgmii1_txd[2]}]
set_property PACKAGE_PIN F10 [get_ports {rgmii1_txd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii1_txd[*]}]

set_property SLEW FAST [get_ports rgmii1_txc]
set_property SLEW FAST [get_ports rgmii1_tx_ctl]
set_property SLEW FAST [get_ports {rgmii1_txd[*]}]

# ETH MDIO and reset
set_property PACKAGE_PIN A15 [get_ports mdc]
set_property IOSTANDARD LVCMOS33 [get_ports mdc]
set_property PACKAGE_PIN B15 [get_ports mdio]
set_property IOSTANDARD LVCMOS33 [get_ports mdio]
set_property PACKAGE_PIN A13 [get_ports eth_rstn]
set_property IOSTANDARD LVCMOS33 [get_ports eth_rstn]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
