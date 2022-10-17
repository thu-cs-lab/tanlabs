# GTP clock 125MHz
set_property PACKAGE_PIN R8 [get_ports gtrefclk_p]
set_property PACKAGE_PIN R7 [get_ports gtrefclk_n]

create_clock -period 8.000 -name gtref_clk -waveform {0.000 4.000} [get_nets gtref_clk]
create_clock -period 5.000 -name ref_clk -waveform {0.000 2.500} [get_nets ref_clk]
create_clock -period 8.000 -name core_clk -waveform {0.000 4.000} [get_nets core_clk]

# Reset Button (KEY1)
set_property PACKAGE_PIN U30 [get_ports RST]
set_property IOSTANDARD LVCMOS33 [get_ports RST]
set_false_path -from [get_ports RST]

# SFP+ 0
set_property PACKAGE_PIN K14 [get_ports {sfp_los[0]}]
set_property PACKAGE_PIN J14 [get_ports {sfp_tx_disable[0]}]
set_property PACKAGE_PIN V5 [get_ports {sfp_rx_n[0]}]
set_property PACKAGE_PIN V6 [get_ports {sfp_rx_p[0]}]
set_property PACKAGE_PIN T1 [get_ports {sfp_tx_n[0]}]
set_property PACKAGE_PIN T2 [get_ports {sfp_tx_p[0]}]

# SFP+ 1
set_property PACKAGE_PIN L15 [get_ports {sfp_los[1]}]
set_property PACKAGE_PIN K15 [get_ports {sfp_tx_disable[1]}]
set_property PACKAGE_PIN AA3 [get_ports {sfp_rx_n[1]}]
set_property PACKAGE_PIN AA4 [get_ports {sfp_rx_p[1]}]
set_property PACKAGE_PIN Y1 [get_ports {sfp_tx_n[1]}]
set_property PACKAGE_PIN Y2 [get_ports {sfp_tx_p[1]}]

# SFP+ 2
set_property PACKAGE_PIN L12 [get_ports {sfp_los[2]}]
set_property PACKAGE_PIN J12 [get_ports {sfp_tx_disable[2]}]
set_property PACKAGE_PIN Y5 [get_ports {sfp_rx_n[2]}]
set_property PACKAGE_PIN Y6 [get_ports {sfp_rx_p[2]}]
set_property PACKAGE_PIN V1 [get_ports {sfp_tx_n[2]}]
set_property PACKAGE_PIN V2 [get_ports {sfp_tx_p[2]}]

# SFP+ 3
set_property PACKAGE_PIN K13 [get_ports {sfp_los[3]}]
set_property PACKAGE_PIN J13 [get_ports {sfp_tx_disable[3]}]
set_property PACKAGE_PIN W3 [get_ports {sfp_rx_n[3]}]
set_property PACKAGE_PIN W4 [get_ports {sfp_rx_p[3]}]
set_property PACKAGE_PIN U3 [get_ports {sfp_tx_n[3]}]
set_property PACKAGE_PIN U4 [get_ports {sfp_tx_p[3]}]

# SFP+ Port LEDs
# D11 E11 J11 K11
# C11 F11 H11 L11
set_property PACKAGE_PIN D11 [get_ports {sfp_link[0]}]
set_property PACKAGE_PIN C11 [get_ports {sfp_link[1]}]
set_property PACKAGE_PIN J11 [get_ports {sfp_link[2]}]
set_property PACKAGE_PIN H11 [get_ports {sfp_link[3]}]
set_property PACKAGE_PIN E11 [get_ports {sfp_act[0]}]
set_property PACKAGE_PIN F11 [get_ports {sfp_act[1]}]
set_property PACKAGE_PIN K11 [get_ports {sfp_act[2]}]
set_property PACKAGE_PIN L11 [get_ports {sfp_act[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {sfp_los[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_tx_disable[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rs[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_link[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_act[*]}]

# ETH1 RGMII
set_property PACKAGE_PIN D26 [get_ports rgmii1_rxc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_rxc]
set_property PACKAGE_PIN E28 [get_ports rgmii1_rx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_rx_ctl]
set_property PACKAGE_PIN F28 [get_ports {rgmii1_rxd[0]}]
set_property PACKAGE_PIN G28 [get_ports {rgmii1_rxd[1]}]
set_property PACKAGE_PIN G27 [get_ports {rgmii1_rxd[2]}]
set_property PACKAGE_PIN H27 [get_ports {rgmii1_rxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii1_rxd[*]}]

set_property PACKAGE_PIN C25 [get_ports rgmii1_txc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_txc]
set_property PACKAGE_PIN G23 [get_ports rgmii1_tx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii1_tx_ctl]
set_property PACKAGE_PIN G24 [get_ports {rgmii1_txd[0]}]
set_property PACKAGE_PIN H24 [get_ports {rgmii1_txd[1]}]
set_property PACKAGE_PIN E23 [get_ports {rgmii1_txd[2]}]
set_property PACKAGE_PIN F23 [get_ports {rgmii1_txd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii1_txd[*]}]

set_property SLEW FAST [get_ports rgmii1_txc]
set_property SLEW FAST [get_ports rgmii1_tx_ctl]
set_property SLEW FAST [get_ports {rgmii1_txd[*]}]

# ETH MDIO and reset
set_property PACKAGE_PIN E21 [get_ports mdc]
set_property IOSTANDARD LVCMOS33 [get_ports mdc]
set_property PACKAGE_PIN F21 [get_ports mdio]
set_property IOSTANDARD LVCMOS33 [get_ports mdio]
# set_property PACKAGE_PIN ?? [get_ports eth_rstn]
# set_property IOSTANDARD LVCMOS33 [get_ports eth_rstn]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
