# Clocks
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD LVCMOS33} [get_ports clk_100M]

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

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list axi_ethernet_0_i/inst/pcs_pma/inst/core_clocking_i/userclk2]]
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ctrl_rx[data][ethertype][0]} {ctrl_rx[data][ethertype][1]} {ctrl_rx[data][ethertype][2]} {ctrl_rx[data][ethertype][3]} {ctrl_rx[data][ethertype][4]} {ctrl_rx[data][ethertype][5]} {ctrl_rx[data][ethertype][6]} {ctrl_rx[data][ethertype][7]} {ctrl_rx[data][ethertype][8]} {ctrl_rx[data][ethertype][9]} {ctrl_rx[data][ethertype][10]} {ctrl_rx[data][ethertype][11]} {ctrl_rx[data][ethertype][12]} {ctrl_rx[data][ethertype][13]} {ctrl_rx[data][ethertype][14]} {ctrl_rx[data][ethertype][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe1]
set_property port_width 272 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {ctrl_rx[data][payload][0]} {ctrl_rx[data][payload][1]} {ctrl_rx[data][payload][2]} {ctrl_rx[data][payload][3]} {ctrl_rx[data][payload][4]} {ctrl_rx[data][payload][5]} {ctrl_rx[data][payload][6]} {ctrl_rx[data][payload][7]} {ctrl_rx[data][payload][8]} {ctrl_rx[data][payload][9]} {ctrl_rx[data][payload][10]} {ctrl_rx[data][payload][11]} {ctrl_rx[data][payload][12]} {ctrl_rx[data][payload][13]} {ctrl_rx[data][payload][14]} {ctrl_rx[data][payload][15]} {ctrl_rx[data][payload][16]} {ctrl_rx[data][payload][17]} {ctrl_rx[data][payload][18]} {ctrl_rx[data][payload][19]} {ctrl_rx[data][payload][20]} {ctrl_rx[data][payload][21]} {ctrl_rx[data][payload][22]} {ctrl_rx[data][payload][23]} {ctrl_rx[data][payload][24]} {ctrl_rx[data][payload][25]} {ctrl_rx[data][payload][26]} {ctrl_rx[data][payload][27]} {ctrl_rx[data][payload][28]} {ctrl_rx[data][payload][29]} {ctrl_rx[data][payload][30]} {ctrl_rx[data][payload][31]} {ctrl_rx[data][payload][32]} {ctrl_rx[data][payload][33]} {ctrl_rx[data][payload][34]} {ctrl_rx[data][payload][35]} {ctrl_rx[data][payload][36]} {ctrl_rx[data][payload][37]} {ctrl_rx[data][payload][38]} {ctrl_rx[data][payload][39]} {ctrl_rx[data][payload][40]} {ctrl_rx[data][payload][41]} {ctrl_rx[data][payload][42]} {ctrl_rx[data][payload][43]} {ctrl_rx[data][payload][44]} {ctrl_rx[data][payload][45]} {ctrl_rx[data][payload][46]} {ctrl_rx[data][payload][47]} {ctrl_rx[data][payload][48]} {ctrl_rx[data][payload][49]} {ctrl_rx[data][payload][50]} {ctrl_rx[data][payload][51]} {ctrl_rx[data][payload][52]} {ctrl_rx[data][payload][53]} {ctrl_rx[data][payload][54]} {ctrl_rx[data][payload][55]} {ctrl_rx[data][payload][56]} {ctrl_rx[data][payload][57]} {ctrl_rx[data][payload][58]} {ctrl_rx[data][payload][59]} {ctrl_rx[data][payload][60]} {ctrl_rx[data][payload][61]} {ctrl_rx[data][payload][62]} {ctrl_rx[data][payload][63]} {ctrl_rx[data][payload][64]} {ctrl_rx[data][payload][65]} {ctrl_rx[data][payload][66]} {ctrl_rx[data][payload][67]} {ctrl_rx[data][payload][68]} {ctrl_rx[data][payload][69]} {ctrl_rx[data][payload][70]} {ctrl_rx[data][payload][71]} {ctrl_rx[data][payload][72]} {ctrl_rx[data][payload][73]} {ctrl_rx[data][payload][74]} {ctrl_rx[data][payload][75]} {ctrl_rx[data][payload][76]} {ctrl_rx[data][payload][77]} {ctrl_rx[data][payload][78]} {ctrl_rx[data][payload][79]} {ctrl_rx[data][payload][80]} {ctrl_rx[data][payload][81]} {ctrl_rx[data][payload][82]} {ctrl_rx[data][payload][83]} {ctrl_rx[data][payload][84]} {ctrl_rx[data][payload][85]} {ctrl_rx[data][payload][86]} {ctrl_rx[data][payload][87]} {ctrl_rx[data][payload][88]} {ctrl_rx[data][payload][89]} {ctrl_rx[data][payload][90]} {ctrl_rx[data][payload][91]} {ctrl_rx[data][payload][92]} {ctrl_rx[data][payload][93]} {ctrl_rx[data][payload][94]} {ctrl_rx[data][payload][95]} {ctrl_rx[data][payload][96]} {ctrl_rx[data][payload][97]} {ctrl_rx[data][payload][98]} {ctrl_rx[data][payload][99]} {ctrl_rx[data][payload][100]} {ctrl_rx[data][payload][101]} {ctrl_rx[data][payload][102]} {ctrl_rx[data][payload][103]} {ctrl_rx[data][payload][104]} {ctrl_rx[data][payload][105]} {ctrl_rx[data][payload][106]} {ctrl_rx[data][payload][107]} {ctrl_rx[data][payload][108]} {ctrl_rx[data][payload][109]} {ctrl_rx[data][payload][110]} {ctrl_rx[data][payload][111]} {ctrl_rx[data][payload][112]} {ctrl_rx[data][payload][113]} {ctrl_rx[data][payload][114]} {ctrl_rx[data][payload][115]} {ctrl_rx[data][payload][116]} {ctrl_rx[data][payload][117]} {ctrl_rx[data][payload][118]} {ctrl_rx[data][payload][119]} {ctrl_rx[data][payload][120]} {ctrl_rx[data][payload][121]} {ctrl_rx[data][payload][122]} {ctrl_rx[data][payload][123]} {ctrl_rx[data][payload][124]} {ctrl_rx[data][payload][125]} {ctrl_rx[data][payload][126]} {ctrl_rx[data][payload][127]} {ctrl_rx[data][payload][128]} {ctrl_rx[data][payload][129]} {ctrl_rx[data][payload][130]} {ctrl_rx[data][payload][131]} {ctrl_rx[data][payload][132]} {ctrl_rx[data][payload][133]} {ctrl_rx[data][payload][134]} {ctrl_rx[data][payload][135]} {ctrl_rx[data][payload][136]} {ctrl_rx[data][payload][137]} {ctrl_rx[data][payload][138]} {ctrl_rx[data][payload][139]} {ctrl_rx[data][payload][140]} {ctrl_rx[data][payload][141]} {ctrl_rx[data][payload][142]} {ctrl_rx[data][payload][143]} {ctrl_rx[data][payload][144]} {ctrl_rx[data][payload][145]} {ctrl_rx[data][payload][146]} {ctrl_rx[data][payload][147]} {ctrl_rx[data][payload][148]} {ctrl_rx[data][payload][149]} {ctrl_rx[data][payload][150]} {ctrl_rx[data][payload][151]} {ctrl_rx[data][payload][152]} {ctrl_rx[data][payload][153]} {ctrl_rx[data][payload][154]} {ctrl_rx[data][payload][155]} {ctrl_rx[data][payload][156]} {ctrl_rx[data][payload][157]} {ctrl_rx[data][payload][158]} {ctrl_rx[data][payload][159]} {ctrl_rx[data][payload][160]} {ctrl_rx[data][payload][161]} {ctrl_rx[data][payload][162]} {ctrl_rx[data][payload][163]} {ctrl_rx[data][payload][164]} {ctrl_rx[data][payload][165]} {ctrl_rx[data][payload][166]} {ctrl_rx[data][payload][167]} {ctrl_rx[data][payload][168]} {ctrl_rx[data][payload][169]} {ctrl_rx[data][payload][170]} {ctrl_rx[data][payload][171]} {ctrl_rx[data][payload][172]} {ctrl_rx[data][payload][173]} {ctrl_rx[data][payload][174]} {ctrl_rx[data][payload][175]} {ctrl_rx[data][payload][176]} {ctrl_rx[data][payload][177]} {ctrl_rx[data][payload][178]} {ctrl_rx[data][payload][179]} {ctrl_rx[data][payload][180]} {ctrl_rx[data][payload][181]} {ctrl_rx[data][payload][182]} {ctrl_rx[data][payload][183]} {ctrl_rx[data][payload][184]} {ctrl_rx[data][payload][185]} {ctrl_rx[data][payload][186]} {ctrl_rx[data][payload][187]} {ctrl_rx[data][payload][188]} {ctrl_rx[data][payload][189]} {ctrl_rx[data][payload][190]} {ctrl_rx[data][payload][191]} {ctrl_rx[data][payload][192]} {ctrl_rx[data][payload][193]} {ctrl_rx[data][payload][194]} {ctrl_rx[data][payload][195]} {ctrl_rx[data][payload][196]} {ctrl_rx[data][payload][197]} {ctrl_rx[data][payload][198]} {ctrl_rx[data][payload][199]} {ctrl_rx[data][payload][200]} {ctrl_rx[data][payload][201]} {ctrl_rx[data][payload][202]} {ctrl_rx[data][payload][203]} {ctrl_rx[data][payload][204]} {ctrl_rx[data][payload][205]} {ctrl_rx[data][payload][206]} {ctrl_rx[data][payload][207]} {ctrl_rx[data][payload][208]} {ctrl_rx[data][payload][209]} {ctrl_rx[data][payload][210]} {ctrl_rx[data][payload][211]} {ctrl_rx[data][payload][212]} {ctrl_rx[data][payload][213]} {ctrl_rx[data][payload][214]} {ctrl_rx[data][payload][215]} {ctrl_rx[data][payload][216]} {ctrl_rx[data][payload][217]} {ctrl_rx[data][payload][218]} {ctrl_rx[data][payload][219]} {ctrl_rx[data][payload][220]} {ctrl_rx[data][payload][221]} {ctrl_rx[data][payload][222]} {ctrl_rx[data][payload][223]} {ctrl_rx[data][payload][224]} {ctrl_rx[data][payload][225]} {ctrl_rx[data][payload][226]} {ctrl_rx[data][payload][227]} {ctrl_rx[data][payload][228]} {ctrl_rx[data][payload][229]} {ctrl_rx[data][payload][230]} {ctrl_rx[data][payload][231]} {ctrl_rx[data][payload][232]} {ctrl_rx[data][payload][233]} {ctrl_rx[data][payload][234]} {ctrl_rx[data][payload][235]} {ctrl_rx[data][payload][236]} {ctrl_rx[data][payload][237]} {ctrl_rx[data][payload][238]} {ctrl_rx[data][payload][239]} {ctrl_rx[data][payload][240]} {ctrl_rx[data][payload][241]} {ctrl_rx[data][payload][242]} {ctrl_rx[data][payload][243]} {ctrl_rx[data][payload][244]} {ctrl_rx[data][payload][245]} {ctrl_rx[data][payload][246]} {ctrl_rx[data][payload][247]} {ctrl_rx[data][payload][248]} {ctrl_rx[data][payload][249]} {ctrl_rx[data][payload][250]} {ctrl_rx[data][payload][251]} {ctrl_rx[data][payload][252]} {ctrl_rx[data][payload][253]} {ctrl_rx[data][payload][254]} {ctrl_rx[data][payload][255]} {ctrl_rx[data][payload][256]} {ctrl_rx[data][payload][257]} {ctrl_rx[data][payload][258]} {ctrl_rx[data][payload][259]} {ctrl_rx[data][payload][260]} {ctrl_rx[data][payload][261]} {ctrl_rx[data][payload][262]} {ctrl_rx[data][payload][263]} {ctrl_rx[data][payload][264]} {ctrl_rx[data][payload][265]} {ctrl_rx[data][payload][266]} {ctrl_rx[data][payload][267]} {ctrl_rx[data][payload][268]} {ctrl_rx[data][payload][269]} {ctrl_rx[data][payload][270]} {ctrl_rx[data][payload][271]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe2]
set_property port_width 48 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {ctrl_rx[data][dst][0]} {ctrl_rx[data][dst][1]} {ctrl_rx[data][dst][2]} {ctrl_rx[data][dst][3]} {ctrl_rx[data][dst][4]} {ctrl_rx[data][dst][5]} {ctrl_rx[data][dst][6]} {ctrl_rx[data][dst][7]} {ctrl_rx[data][dst][8]} {ctrl_rx[data][dst][9]} {ctrl_rx[data][dst][10]} {ctrl_rx[data][dst][11]} {ctrl_rx[data][dst][12]} {ctrl_rx[data][dst][13]} {ctrl_rx[data][dst][14]} {ctrl_rx[data][dst][15]} {ctrl_rx[data][dst][16]} {ctrl_rx[data][dst][17]} {ctrl_rx[data][dst][18]} {ctrl_rx[data][dst][19]} {ctrl_rx[data][dst][20]} {ctrl_rx[data][dst][21]} {ctrl_rx[data][dst][22]} {ctrl_rx[data][dst][23]} {ctrl_rx[data][dst][24]} {ctrl_rx[data][dst][25]} {ctrl_rx[data][dst][26]} {ctrl_rx[data][dst][27]} {ctrl_rx[data][dst][28]} {ctrl_rx[data][dst][29]} {ctrl_rx[data][dst][30]} {ctrl_rx[data][dst][31]} {ctrl_rx[data][dst][32]} {ctrl_rx[data][dst][33]} {ctrl_rx[data][dst][34]} {ctrl_rx[data][dst][35]} {ctrl_rx[data][dst][36]} {ctrl_rx[data][dst][37]} {ctrl_rx[data][dst][38]} {ctrl_rx[data][dst][39]} {ctrl_rx[data][dst][40]} {ctrl_rx[data][dst][41]} {ctrl_rx[data][dst][42]} {ctrl_rx[data][dst][43]} {ctrl_rx[data][dst][44]} {ctrl_rx[data][dst][45]} {ctrl_rx[data][dst][46]} {ctrl_rx[data][dst][47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe3]
set_property port_width 48 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {ctrl_rx[user][0]} {ctrl_rx[user][1]} {ctrl_rx[user][2]} {ctrl_rx[user][3]} {ctrl_rx[user][4]} {ctrl_rx[user][5]} {ctrl_rx[user][6]} {ctrl_rx[user][7]} {ctrl_rx[user][8]} {ctrl_rx[user][9]} {ctrl_rx[user][10]} {ctrl_rx[user][11]} {ctrl_rx[user][12]} {ctrl_rx[user][13]} {ctrl_rx[user][14]} {ctrl_rx[user][15]} {ctrl_rx[user][16]} {ctrl_rx[user][17]} {ctrl_rx[user][18]} {ctrl_rx[user][19]} {ctrl_rx[user][20]} {ctrl_rx[user][21]} {ctrl_rx[user][22]} {ctrl_rx[user][23]} {ctrl_rx[user][24]} {ctrl_rx[user][25]} {ctrl_rx[user][26]} {ctrl_rx[user][27]} {ctrl_rx[user][28]} {ctrl_rx[user][29]} {ctrl_rx[user][30]} {ctrl_rx[user][31]} {ctrl_rx[user][32]} {ctrl_rx[user][33]} {ctrl_rx[user][34]} {ctrl_rx[user][35]} {ctrl_rx[user][36]} {ctrl_rx[user][37]} {ctrl_rx[user][38]} {ctrl_rx[user][39]} {ctrl_rx[user][40]} {ctrl_rx[user][41]} {ctrl_rx[user][42]} {ctrl_rx[user][43]} {ctrl_rx[user][44]} {ctrl_rx[user][45]} {ctrl_rx[user][46]} {ctrl_rx[user][47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe4]
set_property port_width 162 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {ctrl_tx[data][payload][80]} {ctrl_tx[data][payload][81]} {ctrl_tx[data][payload][82]} {ctrl_tx[data][payload][83]} {ctrl_tx[data][payload][84]} {ctrl_tx[data][payload][85]} {ctrl_tx[data][payload][86]} {ctrl_tx[data][payload][87]} {ctrl_tx[data][payload][88]} {ctrl_tx[data][payload][89]} {ctrl_tx[data][payload][90]} {ctrl_tx[data][payload][91]} {ctrl_tx[data][payload][92]} {ctrl_tx[data][payload][93]} {ctrl_tx[data][payload][94]} {ctrl_tx[data][payload][95]} {ctrl_tx[data][payload][115]} {ctrl_tx[data][payload][123]} {ctrl_tx[data][payload][126]} {ctrl_tx[data][payload][128]} {ctrl_tx[data][payload][129]} {ctrl_tx[data][payload][130]} {ctrl_tx[data][payload][131]} {ctrl_tx[data][payload][132]} {ctrl_tx[data][payload][133]} {ctrl_tx[data][payload][134]} {ctrl_tx[data][payload][135]} {ctrl_tx[data][payload][136]} {ctrl_tx[data][payload][137]} {ctrl_tx[data][payload][138]} {ctrl_tx[data][payload][139]} {ctrl_tx[data][payload][140]} {ctrl_tx[data][payload][141]} {ctrl_tx[data][payload][142]} {ctrl_tx[data][payload][143]} {ctrl_tx[data][payload][144]} {ctrl_tx[data][payload][145]} {ctrl_tx[data][payload][146]} {ctrl_tx[data][payload][147]} {ctrl_tx[data][payload][148]} {ctrl_tx[data][payload][149]} {ctrl_tx[data][payload][150]} {ctrl_tx[data][payload][151]} {ctrl_tx[data][payload][152]} {ctrl_tx[data][payload][153]} {ctrl_tx[data][payload][154]} {ctrl_tx[data][payload][155]} {ctrl_tx[data][payload][156]} {ctrl_tx[data][payload][157]} {ctrl_tx[data][payload][158]} {ctrl_tx[data][payload][159]} {ctrl_tx[data][payload][160]} {ctrl_tx[data][payload][161]} {ctrl_tx[data][payload][162]} {ctrl_tx[data][payload][163]} {ctrl_tx[data][payload][164]} {ctrl_tx[data][payload][165]} {ctrl_tx[data][payload][166]} {ctrl_tx[data][payload][167]} {ctrl_tx[data][payload][168]} {ctrl_tx[data][payload][169]} {ctrl_tx[data][payload][170]} {ctrl_tx[data][payload][171]} {ctrl_tx[data][payload][172]} {ctrl_tx[data][payload][173]} {ctrl_tx[data][payload][174]} {ctrl_tx[data][payload][175]} {ctrl_tx[data][payload][176]} {ctrl_tx[data][payload][177]} {ctrl_tx[data][payload][178]} {ctrl_tx[data][payload][179]} {ctrl_tx[data][payload][180]} {ctrl_tx[data][payload][181]} {ctrl_tx[data][payload][182]} {ctrl_tx[data][payload][183]} {ctrl_tx[data][payload][184]} {ctrl_tx[data][payload][185]} {ctrl_tx[data][payload][186]} {ctrl_tx[data][payload][187]} {ctrl_tx[data][payload][188]} {ctrl_tx[data][payload][189]} {ctrl_tx[data][payload][190]} {ctrl_tx[data][payload][191]} {ctrl_tx[data][payload][192]} {ctrl_tx[data][payload][193]} {ctrl_tx[data][payload][194]} {ctrl_tx[data][payload][195]} {ctrl_tx[data][payload][196]} {ctrl_tx[data][payload][197]} {ctrl_tx[data][payload][198]} {ctrl_tx[data][payload][199]} {ctrl_tx[data][payload][200]} {ctrl_tx[data][payload][201]} {ctrl_tx[data][payload][202]} {ctrl_tx[data][payload][203]} {ctrl_tx[data][payload][204]} {ctrl_tx[data][payload][205]} {ctrl_tx[data][payload][206]} {ctrl_tx[data][payload][207]} {ctrl_tx[data][payload][208]} {ctrl_tx[data][payload][209]} {ctrl_tx[data][payload][210]} {ctrl_tx[data][payload][211]} {ctrl_tx[data][payload][212]} {ctrl_tx[data][payload][213]} {ctrl_tx[data][payload][214]} {ctrl_tx[data][payload][215]} {ctrl_tx[data][payload][216]} {ctrl_tx[data][payload][217]} {ctrl_tx[data][payload][218]} {ctrl_tx[data][payload][219]} {ctrl_tx[data][payload][220]} {ctrl_tx[data][payload][221]} {ctrl_tx[data][payload][222]} {ctrl_tx[data][payload][223]} {ctrl_tx[data][payload][224]} {ctrl_tx[data][payload][225]} {ctrl_tx[data][payload][226]} {ctrl_tx[data][payload][227]} {ctrl_tx[data][payload][228]} {ctrl_tx[data][payload][229]} {ctrl_tx[data][payload][230]} {ctrl_tx[data][payload][232]} {ctrl_tx[data][payload][233]} {ctrl_tx[data][payload][234]} {ctrl_tx[data][payload][235]} {ctrl_tx[data][payload][236]} {ctrl_tx[data][payload][237]} {ctrl_tx[data][payload][238]} {ctrl_tx[data][payload][239]} {ctrl_tx[data][payload][240]} {ctrl_tx[data][payload][241]} {ctrl_tx[data][payload][242]} {ctrl_tx[data][payload][243]} {ctrl_tx[data][payload][244]} {ctrl_tx[data][payload][245]} {ctrl_tx[data][payload][246]} {ctrl_tx[data][payload][247]} {ctrl_tx[data][payload][248]} {ctrl_tx[data][payload][249]} {ctrl_tx[data][payload][250]} {ctrl_tx[data][payload][251]} {ctrl_tx[data][payload][252]} {ctrl_tx[data][payload][253]} {ctrl_tx[data][payload][254]} {ctrl_tx[data][payload][255]} {ctrl_tx[data][payload][256]} {ctrl_tx[data][payload][257]} {ctrl_tx[data][payload][258]} {ctrl_tx[data][payload][259]} {ctrl_tx[data][payload][260]} {ctrl_tx[data][payload][261]} {ctrl_tx[data][payload][262]} {ctrl_tx[data][payload][263]} {ctrl_tx[data][payload][264]} {ctrl_tx[data][payload][265]} {ctrl_tx[data][payload][266]} {ctrl_tx[data][payload][267]} {ctrl_tx[data][payload][268]} {ctrl_tx[data][payload][269]} {ctrl_tx[data][payload][270]} {ctrl_tx[data][payload][271]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {ctrl_tx[data][src][0]} {ctrl_tx[data][src][1]} {ctrl_tx[data][src][2]} {ctrl_tx[data][src][3]} {ctrl_tx[data][src][4]} {ctrl_tx[data][src][5]} {ctrl_tx[data][src][6]} {ctrl_tx[data][src][7]} {ctrl_tx[data][src][8]} {ctrl_tx[data][src][9]} {ctrl_tx[data][src][10]} {ctrl_tx[data][src][11]} {ctrl_tx[data][src][12]} {ctrl_tx[data][src][13]} {ctrl_tx[data][src][14]} {ctrl_tx[data][src][15]} {ctrl_tx[data][src][16]} {ctrl_tx[data][src][17]} {ctrl_tx[data][src][18]} {ctrl_tx[data][src][19]} {ctrl_tx[data][src][20]} {ctrl_tx[data][src][21]} {ctrl_tx[data][src][22]} {ctrl_tx[data][src][23]} {ctrl_tx[data][src][24]} {ctrl_tx[data][src][25]} {ctrl_tx[data][src][26]} {ctrl_tx[data][src][27]} {ctrl_tx[data][src][28]} {ctrl_tx[data][src][29]} {ctrl_tx[data][src][30]} {ctrl_tx[data][src][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {ctrl_tx[keep][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe7]
set_property port_width 48 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {ctrl_rx[keep][0]} {ctrl_rx[keep][1]} {ctrl_rx[keep][2]} {ctrl_rx[keep][3]} {ctrl_rx[keep][4]} {ctrl_rx[keep][5]} {ctrl_rx[keep][6]} {ctrl_rx[keep][7]} {ctrl_rx[keep][8]} {ctrl_rx[keep][9]} {ctrl_rx[keep][10]} {ctrl_rx[keep][11]} {ctrl_rx[keep][12]} {ctrl_rx[keep][13]} {ctrl_rx[keep][14]} {ctrl_rx[keep][15]} {ctrl_rx[keep][16]} {ctrl_rx[keep][17]} {ctrl_rx[keep][18]} {ctrl_rx[keep][19]} {ctrl_rx[keep][20]} {ctrl_rx[keep][21]} {ctrl_rx[keep][22]} {ctrl_rx[keep][23]} {ctrl_rx[keep][24]} {ctrl_rx[keep][25]} {ctrl_rx[keep][26]} {ctrl_rx[keep][27]} {ctrl_rx[keep][28]} {ctrl_rx[keep][29]} {ctrl_rx[keep][30]} {ctrl_rx[keep][31]} {ctrl_rx[keep][32]} {ctrl_rx[keep][33]} {ctrl_rx[keep][34]} {ctrl_rx[keep][35]} {ctrl_rx[keep][36]} {ctrl_rx[keep][37]} {ctrl_rx[keep][38]} {ctrl_rx[keep][39]} {ctrl_rx[keep][40]} {ctrl_rx[keep][41]} {ctrl_rx[keep][42]} {ctrl_rx[keep][43]} {ctrl_rx[keep][44]} {ctrl_rx[keep][45]} {ctrl_rx[keep][46]} {ctrl_rx[keep][47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe8]
set_property port_width 48 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {ctrl_rx[data][src][0]} {ctrl_rx[data][src][1]} {ctrl_rx[data][src][2]} {ctrl_rx[data][src][3]} {ctrl_rx[data][src][4]} {ctrl_rx[data][src][5]} {ctrl_rx[data][src][6]} {ctrl_rx[data][src][7]} {ctrl_rx[data][src][8]} {ctrl_rx[data][src][9]} {ctrl_rx[data][src][10]} {ctrl_rx[data][src][11]} {ctrl_rx[data][src][12]} {ctrl_rx[data][src][13]} {ctrl_rx[data][src][14]} {ctrl_rx[data][src][15]} {ctrl_rx[data][src][16]} {ctrl_rx[data][src][17]} {ctrl_rx[data][src][18]} {ctrl_rx[data][src][19]} {ctrl_rx[data][src][20]} {ctrl_rx[data][src][21]} {ctrl_rx[data][src][22]} {ctrl_rx[data][src][23]} {ctrl_rx[data][src][24]} {ctrl_rx[data][src][25]} {ctrl_rx[data][src][26]} {ctrl_rx[data][src][27]} {ctrl_rx[data][src][28]} {ctrl_rx[data][src][29]} {ctrl_rx[data][src][30]} {ctrl_rx[data][src][31]} {ctrl_rx[data][src][32]} {ctrl_rx[data][src][33]} {ctrl_rx[data][src][34]} {ctrl_rx[data][src][35]} {ctrl_rx[data][src][36]} {ctrl_rx[data][src][37]} {ctrl_rx[data][src][38]} {ctrl_rx[data][src][39]} {ctrl_rx[data][src][40]} {ctrl_rx[data][src][41]} {ctrl_rx[data][src][42]} {ctrl_rx[data][src][43]} {ctrl_rx[data][src][44]} {ctrl_rx[data][src][45]} {ctrl_rx[data][src][46]} {ctrl_rx[data][src][47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe9]
set_property port_width 48 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {ctrl_tx[data][dst][0]} {ctrl_tx[data][dst][1]} {ctrl_tx[data][dst][2]} {ctrl_tx[data][dst][3]} {ctrl_tx[data][dst][4]} {ctrl_tx[data][dst][5]} {ctrl_tx[data][dst][6]} {ctrl_tx[data][dst][7]} {ctrl_tx[data][dst][8]} {ctrl_tx[data][dst][9]} {ctrl_tx[data][dst][10]} {ctrl_tx[data][dst][11]} {ctrl_tx[data][dst][12]} {ctrl_tx[data][dst][13]} {ctrl_tx[data][dst][14]} {ctrl_tx[data][dst][15]} {ctrl_tx[data][dst][16]} {ctrl_tx[data][dst][17]} {ctrl_tx[data][dst][18]} {ctrl_tx[data][dst][19]} {ctrl_tx[data][dst][20]} {ctrl_tx[data][dst][21]} {ctrl_tx[data][dst][22]} {ctrl_tx[data][dst][23]} {ctrl_tx[data][dst][24]} {ctrl_tx[data][dst][25]} {ctrl_tx[data][dst][26]} {ctrl_tx[data][dst][27]} {ctrl_tx[data][dst][28]} {ctrl_tx[data][dst][29]} {ctrl_tx[data][dst][30]} {ctrl_tx[data][dst][31]} {ctrl_tx[data][dst][32]} {ctrl_tx[data][dst][33]} {ctrl_tx[data][dst][34]} {ctrl_tx[data][dst][35]} {ctrl_tx[data][dst][36]} {ctrl_tx[data][dst][37]} {ctrl_tx[data][dst][38]} {ctrl_tx[data][dst][39]} {ctrl_tx[data][dst][40]} {ctrl_tx[data][dst][41]} {ctrl_tx[data][dst][42]} {ctrl_tx[data][dst][43]} {ctrl_tx[data][dst][44]} {ctrl_tx[data][dst][45]} {ctrl_tx[data][dst][46]} {ctrl_tx[data][dst][47]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe10]
set_property port_width 8 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {eth_rx8_data[4][0]} {eth_rx8_data[4][1]} {eth_rx8_data[4][2]} {eth_rx8_data[4][3]} {eth_rx8_data[4][4]} {eth_rx8_data[4][5]} {eth_rx8_data[4][6]} {eth_rx8_data[4][7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe11]
set_property port_width 8 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {eth_tx8_data[4][0]} {eth_tx8_data[4][1]} {eth_tx8_data[4][2]} {eth_tx8_data[4][3]} {eth_tx8_data[4][4]} {eth_tx8_data[4][5]} {eth_tx8_data[4][6]} {eth_tx8_data[4][7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {ctrl_rx[last]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {ctrl_rx[valid]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {ctrl_tx[last]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {ctrl_tx[valid]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list ctrl_tx_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {eth_tx8_last[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {eth_tx8_ready[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {eth_tx8_user[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {eth_tx8_valid[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {eth_rx8_last[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {eth_rx8_user[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {eth_rx8_valid[4]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets eth_clk]
