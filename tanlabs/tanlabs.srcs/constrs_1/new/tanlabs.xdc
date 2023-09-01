# Clocks
set_property -dict {PACKAGE_PIN AH10 IOSTANDARD LVDS} [get_ports sysclk_100_n] ;# SYSCLK_N
set_property -dict {PACKAGE_PIN AG10 IOSTANDARD LVDS} [get_ports sysclk_100_p] ;# SYSCLK_P 100MHz
set_property -dict {PACKAGE_PIN T26 IOSTANDARD LVCMOS33} [get_ports clk_50M] ;# CLK_IN0 50MHz main clock input
set_property -dict {PACKAGE_PIN U27 IOSTANDARD LVCMOS33} [get_ports clk_11M0592] ;# CLK_IN1 11.0592MHz clock for UART

create_clock -period 10.000 -name sysclk_100 -waveform {0.000 5.000} [get_ports sysclk_100_p]
create_clock -period 20.000 -name clk_50M -waveform {0.000 10.000} [get_ports clk_50M]
create_clock -period 90.422 -name clk_11M0592 -waveform {0.000 45.211} [get_ports clk_11M0592]

# GT clocks 125MHz, 156.25MHz
set_property PACKAGE_PIN R7 [get_ports gtclk_125_n] ;# MGT_CLK0_N
set_property PACKAGE_PIN R8 [get_ports gtclk_125_p] ;# MGT_CLK0_P
set_property PACKAGE_PIN U7 [get_ports gtclk_15625_n] ;# MGT_CLK1_N
set_property PACKAGE_PIN U8 [get_ports gtclk_15625_p] ;# MGT_CLK1_P

create_clock -period 8.000 -name gtclk_125 -waveform {0.000 4.000} [get_ports gtclk_125_p]
create_clock -period 6.400 -name gtclk_15625 -waveform {0.000 3.200} [get_ports gtclk_15625_p]

# Reset Button (BTN6)
set_property -dict {PACKAGE_PIN U30 IOSTANDARD LVCMOS33} [get_ports RST]
set_false_path -from [get_ports RST]

# Clock Button (BTN5)
set_property -dict {PACKAGE_PIN V30 IOSTANDARD LVCMOS33} [get_ports BTN]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets BTN_IBUF]

# Buttons
set_property -dict {PACKAGE_PIN W26 IOSTANDARD LVCMOS33} [get_ports touch_btn[0]] ;# BTN0
set_property -dict {PACKAGE_PIN W27 IOSTANDARD LVCMOS33} [get_ports touch_btn[1]] ;# BTN1
set_property -dict {PACKAGE_PIN W29 IOSTANDARD LVCMOS33} [get_ports touch_btn[2]] ;# BTN2
set_property -dict {PACKAGE_PIN V29 IOSTANDARD LVCMOS33} [get_ports touch_btn[3]] ;# BTN3

# GPIOs
set_property -dict {PACKAGE_PIN AJ21 IOSTANDARD LVCMOS33} [get_ports ext_io[0]] ;# EXIO0
set_property -dict {PACKAGE_PIN AK21 IOSTANDARD LVCMOS33} [get_ports ext_io[1]] ;# EXIO1
set_property -dict {PACKAGE_PIN AJ22 IOSTANDARD LVCMOS33} [get_ports ext_io[2]] ;# EXIO2
set_property -dict {PACKAGE_PIN AJ23 IOSTANDARD LVCMOS33} [get_ports ext_io[3]] ;# EXIO3
set_property -dict {PACKAGE_PIN AK23 IOSTANDARD LVCMOS33} [get_ports ext_io[4]] ;# EXIO4
set_property -dict {PACKAGE_PIN AH20 IOSTANDARD LVCMOS33} [get_ports ext_io[5]] ;# EXIO5
set_property -dict {PACKAGE_PIN AH21 IOSTANDARD LVCMOS33} [get_ports ext_io[6]] ;# EXIO6
set_property -dict {PACKAGE_PIN AK20 IOSTANDARD LVCMOS33} [get_ports ext_io[7]] ;# EXIO7

# HDMI
set_property -dict {PACKAGE_PIN M28 IOSTANDARD LVCMOS33} [get_ports hdmi_ddc_scl] ;# HDMI_DDC_SCL
set_property -dict {PACKAGE_PIN M27 IOSTANDARD LVCMOS33} [get_ports hdmi_ddc_sda] ;# HDMI_DDC_SDA
set_property -dict {PACKAGE_PIN N27 IOSTANDARD LVCMOS33} [get_ports hdmi_hotplug] ;# HDMI_HOTPLUG
set_property -dict {PACKAGE_PIN L27 IOSTANDARD TMDS_33} [get_ports hdmi_data_n[0]] ;# HDMI_TMDS0_N
set_property -dict {PACKAGE_PIN L26 IOSTANDARD TMDS_33} [get_ports hdmi_data_p[0]] ;# HDMI_TMDS0_P
set_property -dict {PACKAGE_PIN K29 IOSTANDARD TMDS_33} [get_ports hdmi_data_n[1]] ;# HDMI_TMDS1_N
set_property -dict {PACKAGE_PIN K28 IOSTANDARD TMDS_33} [get_ports hdmi_data_p[1]] ;# HDMI_TMDS1_P
set_property -dict {PACKAGE_PIN J28 IOSTANDARD TMDS_33} [get_ports hdmi_data_n[2]] ;# HDMI_TMDS2_N
set_property -dict {PACKAGE_PIN J27 IOSTANDARD TMDS_33} [get_ports hdmi_data_p[2]] ;# HDMI_TMDS2_P
set_property -dict {PACKAGE_PIN M30 IOSTANDARD TMDS_33} [get_ports hdmi_clock_n] ;# HDMI_TMDSC_N
set_property -dict {PACKAGE_PIN M29 IOSTANDARD TMDS_33} [get_ports hdmi_clock_p] ;# HDMI_TMDSC_P

# LEDs
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports led[0]] ;# LED0
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports led[1]] ;# LED1
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports led[2]] ;# LED2
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports led[3]] ;# LED3
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports led[4]] ;# LED4
set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33} [get_ports led[5]] ;# LED5
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports led[6]] ;# LED6
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports led[7]] ;# LED7
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports led[8]] ;# LED8
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports led[9]] ;# LED9
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports led[10]] ;# LED10
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports led[11]] ;# LED11
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports led[12]] ;# LED12
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports led[13]] ;# LED13
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports led[14]] ;# LED14
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports led[15]] ;# LED15

# DPY0
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports dpy0[0]] ;# LED16
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports dpy0[1]] ;# LED17
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports dpy0[2]] ;# LED18
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports dpy0[3]] ;# LED19
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports dpy0[4]] ;# LED20
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports dpy0[5]] ;# LED21
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports dpy0[6]] ;# LED22
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports dpy0[7]] ;# LED23

# DPY1
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports dpy1[0]] ;# LED24
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports dpy1[1]] ;# LED25
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS33} [get_ports dpy1[2]] ;# LED26
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33} [get_ports dpy1[3]] ;# LED27
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports dpy1[4]] ;# LED28
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports dpy1[5]] ;# LED29
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports dpy1[6]] ;# LED30
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports dpy1[7]] ;# LED31

# DIP Switch
set_property -dict {PACKAGE_PIN AK25 IOSTANDARD LVCMOS33} [get_ports dip_sw[0]] ;# SW0
set_property -dict {PACKAGE_PIN AK26 IOSTANDARD LVCMOS33} [get_ports dip_sw[1]] ;# SW1
set_property -dict {PACKAGE_PIN AJ26 IOSTANDARD LVCMOS33} [get_ports dip_sw[2]] ;# SW2
set_property -dict {PACKAGE_PIN AJ27 IOSTANDARD LVCMOS33} [get_ports dip_sw[3]] ;# SW3
set_property -dict {PACKAGE_PIN AK28 IOSTANDARD LVCMOS33} [get_ports dip_sw[4]] ;# SW4
set_property -dict {PACKAGE_PIN AJ28 IOSTANDARD LVCMOS33} [get_ports dip_sw[5]] ;# SW5
set_property -dict {PACKAGE_PIN AK29 IOSTANDARD LVCMOS33} [get_ports dip_sw[6]] ;# SW6
set_property -dict {PACKAGE_PIN AK30 IOSTANDARD LVCMOS33} [get_ports dip_sw[7]] ;# SW7
set_property -dict {PACKAGE_PIN AF23 IOSTANDARD LVCMOS33} [get_ports dip_sw[8]] ;# SW8
set_property -dict {PACKAGE_PIN AG23 IOSTANDARD LVCMOS33} [get_ports dip_sw[9]] ;# SW9
set_property -dict {PACKAGE_PIN AD23 IOSTANDARD LVCMOS33} [get_ports dip_sw[10]] ;# SW10
set_property -dict {PACKAGE_PIN AE23 IOSTANDARD LVCMOS33} [get_ports dip_sw[11]] ;# SW11
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports dip_sw[12]] ;# SW12
set_property -dict {PACKAGE_PIN AC22 IOSTANDARD LVCMOS33} [get_ports dip_sw[13]] ;# SW13
set_property -dict {PACKAGE_PIN AF22 IOSTANDARD LVCMOS33} [get_ports dip_sw[14]] ;# SW14
set_property -dict {PACKAGE_PIN AH22 IOSTANDARD LVCMOS33} [get_ports dip_sw[15]] ;# SW15

# BaseRAM
set_property -dict {PACKAGE_PIN AB27 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[0]] ;# BASE_RAM_A0
set_property -dict {PACKAGE_PIN AC27 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[1]] ;# BASE_RAM_A1
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[2]] ;# BASE_RAM_A2
set_property -dict {PACKAGE_PIN AD28 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[3]] ;# BASE_RAM_A3
set_property -dict {PACKAGE_PIN AD27 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[4]] ;# BASE_RAM_A4
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[5]] ;# BASE_RAM_A5
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[6]] ;# BASE_RAM_A6
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[7]] ;# BASE_RAM_A7
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[8]] ;# BASE_RAM_A8
set_property -dict {PACKAGE_PIN AF27 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[9]] ;# BASE_RAM_A9
set_property -dict {PACKAGE_PIN AF28 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[10]] ;# BASE_RAM_A10
set_property -dict {PACKAGE_PIN AG27 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[11]] ;# BASE_RAM_A11
set_property -dict {PACKAGE_PIN AG28 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[12]] ;# BASE_RAM_A12
set_property -dict {PACKAGE_PIN AH26 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[13]] ;# BASE_RAM_A13
set_property -dict {PACKAGE_PIN AH27 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[14]] ;# BASE_RAM_A14
set_property -dict {PACKAGE_PIN AJ29 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[15]] ;# BASE_RAM_A15
set_property -dict {PACKAGE_PIN AH30 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[16]] ;# BASE_RAM_A16
set_property -dict {PACKAGE_PIN AH29 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[17]] ;# BASE_RAM_A17
set_property -dict {PACKAGE_PIN AG30 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[18]] ;# BASE_RAM_A18
set_property -dict {PACKAGE_PIN AF30 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[19]] ;# BASE_RAM_A19
set_property -dict {PACKAGE_PIN AE28 IOSTANDARD LVCMOS33} [get_ports base_ram_addr[20]] ;# BASE_RAM_A20
set_property -dict {PACKAGE_PIN AD26 IOSTANDARD LVCMOS33} [get_ports base_ram_be_n[0]] ;# BASE_RAM_BE0
set_property -dict {PACKAGE_PIN AD24 IOSTANDARD LVCMOS33} [get_ports base_ram_be_n[1]] ;# BASE_RAM_BE1
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33} [get_ports base_ram_be_n[2]] ;# BASE_RAM_BE2
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS33} [get_ports base_ram_be_n[3]] ;# BASE_RAM_BE3
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS33} [get_ports base_ram_ce_n] ;# BASE_RAM_CE
set_property -dict {PACKAGE_PIN Y24 IOSTANDARD LVCMOS33} [get_ports base_ram_data[0]] ;# BASE_RAM_D0
set_property -dict {PACKAGE_PIN Y25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[1]] ;# BASE_RAM_D1
set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[2]] ;# BASE_RAM_D2
set_property -dict {PACKAGE_PIN AA26 IOSTANDARD LVCMOS33} [get_ports base_ram_data[3]] ;# BASE_RAM_D3
set_property -dict {PACKAGE_PIN AB24 IOSTANDARD LVCMOS33} [get_ports base_ram_data[4]] ;# BASE_RAM_D4
set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[5]] ;# BASE_RAM_D5
set_property -dict {PACKAGE_PIN AC24 IOSTANDARD LVCMOS33} [get_ports base_ram_data[6]] ;# BASE_RAM_D6
set_property -dict {PACKAGE_PIN AC25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[7]] ;# BASE_RAM_D7
set_property -dict {PACKAGE_PIN AH25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[8]] ;# BASE_RAM_D8
set_property -dict {PACKAGE_PIN AH24 IOSTANDARD LVCMOS33} [get_ports base_ram_data[9]] ;# BASE_RAM_D9
set_property -dict {PACKAGE_PIN AG25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[10]] ;# BASE_RAM_D10
set_property -dict {PACKAGE_PIN AG24 IOSTANDARD LVCMOS33} [get_ports base_ram_data[11]] ;# BASE_RAM_D11
set_property -dict {PACKAGE_PIN AF26 IOSTANDARD LVCMOS33} [get_ports base_ram_data[12]] ;# BASE_RAM_D12
set_property -dict {PACKAGE_PIN AF25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[13]] ;# BASE_RAM_D13
set_property -dict {PACKAGE_PIN AE25 IOSTANDARD LVCMOS33} [get_ports base_ram_data[14]] ;# BASE_RAM_D14
set_property -dict {PACKAGE_PIN AE24 IOSTANDARD LVCMOS33} [get_ports base_ram_data[15]] ;# BASE_RAM_D15
set_property -dict {PACKAGE_PIN Y30 IOSTANDARD LVCMOS33} [get_ports base_ram_data[16]] ;# BASE_RAM_D16
set_property -dict {PACKAGE_PIN Y29 IOSTANDARD LVCMOS33} [get_ports base_ram_data[17]] ;# BASE_RAM_D17
set_property -dict {PACKAGE_PIN AA30 IOSTANDARD LVCMOS33} [get_ports base_ram_data[18]] ;# BASE_RAM_D18
set_property -dict {PACKAGE_PIN AB30 IOSTANDARD LVCMOS33} [get_ports base_ram_data[19]] ;# BASE_RAM_D19
set_property -dict {PACKAGE_PIN AC29 IOSTANDARD LVCMOS33} [get_ports base_ram_data[20]] ;# BASE_RAM_D20
set_property -dict {PACKAGE_PIN AC30 IOSTANDARD LVCMOS33} [get_ports base_ram_data[21]] ;# BASE_RAM_D21
set_property -dict {PACKAGE_PIN AD29 IOSTANDARD LVCMOS33} [get_ports base_ram_data[22]] ;# BASE_RAM_D22
set_property -dict {PACKAGE_PIN AE30 IOSTANDARD LVCMOS33} [get_ports base_ram_data[23]] ;# BASE_RAM_D23
set_property -dict {PACKAGE_PIN E26 IOSTANDARD LVCMOS33} [get_ports base_ram_data[24]] ;# BASE_RAM_D24
set_property -dict {PACKAGE_PIN F26 IOSTANDARD LVCMOS33} [get_ports base_ram_data[25]] ;# BASE_RAM_D25
set_property -dict {PACKAGE_PIN C27 IOSTANDARD LVCMOS33} [get_ports base_ram_data[26]] ;# BASE_RAM_D26
set_property -dict {PACKAGE_PIN D27 IOSTANDARD LVCMOS33} [get_ports base_ram_data[27]] ;# BASE_RAM_D27
set_property -dict {PACKAGE_PIN C21 IOSTANDARD LVCMOS33} [get_ports base_ram_data[28]] ;# BASE_RAM_D28
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports base_ram_data[29]] ;# BASE_RAM_D29
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33} [get_ports base_ram_data[30]] ;# BASE_RAM_D30
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports base_ram_data[31]] ;# BASE_RAM_D31
set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVCMOS33} [get_ports base_ram_oe_n] ;# BASE_RAM_OE
set_property -dict {PACKAGE_PIN AE29 IOSTANDARD LVCMOS33} [get_ports base_ram_we_n] ;# BASE_RAM_WE

# RGMII
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33} [get_ports rgmii_mdc] ;# RGMII_MDC
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33} [get_ports rgmii_mdio] ;# RGMII_MDIO
set_property -dict {PACKAGE_PIN D26 IOSTANDARD LVCMOS33} [get_ports rgmii_rxclk] ;# RGMII_RXCLK
set_property -dict {PACKAGE_PIN E28 IOSTANDARD LVCMOS33} [get_ports rgmii_rxctl] ;# RGMII_RXCTL
set_property -dict {PACKAGE_PIN F28 IOSTANDARD LVCMOS33} [get_ports rgmii_rxd[0]] ;# RGMII_RXD0
set_property -dict {PACKAGE_PIN G28 IOSTANDARD LVCMOS33} [get_ports rgmii_rxd[1]] ;# RGMII_RXD1
set_property -dict {PACKAGE_PIN G27 IOSTANDARD LVCMOS33} [get_ports rgmii_rxd[2]] ;# RGMII_RXD2
set_property -dict {PACKAGE_PIN H27 IOSTANDARD LVCMOS33} [get_ports rgmii_rxd[3]] ;# RGMII_RXD3
set_property -dict {PACKAGE_PIN C25 IOSTANDARD LVCMOS33} [get_ports rgmii_txclk] ;# RGMII_TXCLK
set_property -dict {PACKAGE_PIN G23 IOSTANDARD LVCMOS33} [get_ports rgmii_txctl] ;# RGMII_TXCTL
set_property -dict {PACKAGE_PIN G24 IOSTANDARD LVCMOS33} [get_ports rgmii_txd[0]] ;# RGMII_TXD0
set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVCMOS33} [get_ports rgmii_txd[1]] ;# RGMII_TXD1
set_property -dict {PACKAGE_PIN E23 IOSTANDARD LVCMOS33} [get_ports rgmii_txd[2]] ;# RGMII_TXD2
set_property -dict {PACKAGE_PIN F23 IOSTANDARD LVCMOS33} [get_ports rgmii_txd[3]] ;# RGMII_TXD3

# SD Card
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports sdcard_clk] ;# TF_CLK
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports sdcard_cmd] ;# TF_CMD
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports sdcard_data[0]] ;# TF_D0
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports sdcard_data[1]] ;# TF_D1
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports sdcard_data[2]] ;# TF_D2
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports sdcard_data[3]] ;# TF_D3
set_property -dict {PACKAGE_PIN F12 IOSTANDARD LVCMOS33} [get_ports sdcard_cd] ;# TF_DET

# USB
set_property -dict {PACKAGE_PIN J23 IOSTANDARD LVCMOS33} [get_ports usb_clk] ;# USB_CLK
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports usb_data[0]] ;# USB_D0
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports usb_data[1]] ;# USB_D1
set_property -dict {PACKAGE_PIN H21 IOSTANDARD LVCMOS33} [get_ports usb_data[2]] ;# USB_D2
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33} [get_ports usb_data[3]] ;# USB_D3
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports usb_data[4]] ;# USB_D4
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports usb_data[5]] ;# USB_D5
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports usb_data[6]] ;# USB_D6
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33} [get_ports usb_data[7]] ;# USB_D7
set_property -dict {PACKAGE_PIN K24 IOSTANDARD LVCMOS33} [get_ports usb_dir] ;# USB_DIR
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS33} [get_ports usb_nxt] ;# USB_NXT
set_property -dict {PACKAGE_PIN C24 IOSTANDARD LVCMOS33} [get_ports usb_reset] ;# USB_RESET
set_property -dict {PACKAGE_PIN J24 IOSTANDARD LVCMOS33} [get_ports usb_stp] ;# USB_STP

# Zynq HSIO
set_property -dict {PACKAGE_PIN D19 IOSTANDARD TMDS_33} [get_ports zynq_hsio_n[0]] ;# HS0_N
set_property -dict {PACKAGE_PIN E19 IOSTANDARD TMDS_33} [get_ports zynq_hsio_p[0]] ;# HS0_P
set_property -dict {PACKAGE_PIN E20 IOSTANDARD TMDS_33} [get_ports zynq_hsio_n[1]] ;# HS1_N
set_property -dict {PACKAGE_PIN F20 IOSTANDARD TMDS_33} [get_ports zynq_hsio_p[1]] ;# HS1_P
set_property -dict {PACKAGE_PIN F17 IOSTANDARD TMDS_33} [get_ports zynq_hsio_n[2]] ;# HS2_N
set_property -dict {PACKAGE_PIN G17 IOSTANDARD TMDS_33} [get_ports zynq_hsio_p[2]] ;# HS2_P
set_property -dict {PACKAGE_PIN F18 IOSTANDARD TMDS_33} [get_ports zynq_hsio_n[3]] ;# HS3_N
set_property -dict {PACKAGE_PIN G18 IOSTANDARD TMDS_33} [get_ports zynq_hsio_p[3]] ;# HS3_P
set_property -dict {PACKAGE_PIN J18 IOSTANDARD TMDS_33} [get_ports zynq_hsio_n[4]] ;# HS4_N
set_property -dict {PACKAGE_PIN K18 IOSTANDARD TMDS_33} [get_ports zynq_hsio_p[4]] ;# HS4_P

# Zynq LSIO
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[0]] ;# LSIO0
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[1]] ;# LSIO1
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[2]] ;# LSIO2
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[3]] ;# LSIO3
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[4]] ;# LSIO4
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[5]] ;# LSIO5
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[6]] ;# LSIO6
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports zynq_lsio[7]] ;# LSIO7
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports uart_tx] ;# LSIO8
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports uart_rx] ;# LSIO9
set_property PULLUP true [get_ports uart_rx]

# SODIMM
set_property PACKAGE_PIN AK10 [get_ports ddr3_addr[0]] ;# SO_A0
set_property PACKAGE_PIN AB10 [get_ports ddr3_addr[1]] ;# SO_A1
set_property PACKAGE_PIN AA11 [get_ports ddr3_addr[2]] ;# SO_A2
set_property PACKAGE_PIN AC10 [get_ports ddr3_addr[3]] ;# SO_A3
set_property PACKAGE_PIN Y11 [get_ports ddr3_addr[4]] ;# SO_A4
set_property PACKAGE_PIN AC9 [get_ports ddr3_addr[5]] ;# SO_A5
set_property PACKAGE_PIN AK9 [get_ports ddr3_addr[6]] ;# SO_A6
set_property PACKAGE_PIN AH9 [get_ports ddr3_addr[7]] ;# SO_A7
set_property PACKAGE_PIN AD9 [get_ports ddr3_addr[8]] ;# SO_A8
set_property PACKAGE_PIN AA10 [get_ports ddr3_addr[9]] ;# SO_A9
set_property PACKAGE_PIN AF10 [get_ports ddr3_addr[10]] ;# SO_A10
set_property PACKAGE_PIN AE9 [get_ports ddr3_addr[11]] ;# SO_A11
set_property PACKAGE_PIN Y10 [get_ports ddr3_addr[12]] ;# SO_A12
set_property PACKAGE_PIN AE8 [get_ports ddr3_addr[13]] ;# SO_A13
set_property PACKAGE_PIN AG9 [get_ports ddr3_addr[14]] ;# SO_A14
set_property PACKAGE_PIN AB9 [get_ports ddr3_addr[15]] ;# SO_A15
set_property PACKAGE_PIN AE10 [get_ports ddr3_ba[0]] ;# SO_BA0
set_property PACKAGE_PIN AB12 [get_ports ddr3_ba[1]] ;# SO_BA1
set_property PACKAGE_PIN AD8 [get_ports ddr3_ba[2]] ;# SO_BA2
set_property PACKAGE_PIN AC12 [get_ports ddr3_cas_n] ;# SO_CAS#
set_property PACKAGE_PIN AF11 [get_ports ddr3_ck_n[0]] ;# SO_CK0_N
set_property PACKAGE_PIN AD11 [get_ports ddr3_ck_n[1]] ;# SO_CK1_N
set_property PACKAGE_PIN AE11 [get_ports ddr3_ck_p[0]] ;# SO_CK0_P
set_property PACKAGE_PIN AD12 [get_ports ddr3_ck_p[1]] ;# SO_CK1_P
set_property PACKAGE_PIN AA8 [get_ports ddr3_cke[0]] ;# SO_CKE0
set_property PACKAGE_PIN AB8 [get_ports ddr3_cke[1]] ;# SO_CKE1
set_property PACKAGE_PIN AH11 [get_ports ddr3_cs_n[0]] ;# SO_S0#
set_property PACKAGE_PIN AA13 [get_ports ddr3_cs_n[1]] ;# SO_S1#
set_property PACKAGE_PIN AD4 [get_ports ddr3_dm[0]] ;# SO_DM0
set_property PACKAGE_PIN AE1 [get_ports ddr3_dm[1]] ;# SO_DM1
set_property PACKAGE_PIN AH4 [get_ports ddr3_dm[2]] ;# SO_DM2
set_property PACKAGE_PIN AG7 [get_ports ddr3_dm[3]] ;# SO_DM3
set_property PACKAGE_PIN AK13 [get_ports ddr3_dm[4]] ;# SO_DM4
set_property PACKAGE_PIN AG15 [get_ports ddr3_dm[5]] ;# SO_DM5
set_property PACKAGE_PIN AK19 [get_ports ddr3_dm[6]] ;# SO_DM6
set_property PACKAGE_PIN AB19 [get_ports ddr3_dm[7]] ;# SO_DM7
set_property PACKAGE_PIN AC4 [get_ports ddr3_dq[0]] ;# SO_DQ0
set_property PACKAGE_PIN AC5 [get_ports ddr3_dq[1]] ;# SO_DQ1
set_property PACKAGE_PIN AD6 [get_ports ddr3_dq[2]] ;# SO_DQ2
set_property PACKAGE_PIN AE6 [get_ports ddr3_dq[3]] ;# SO_DQ3
set_property PACKAGE_PIN AC1 [get_ports ddr3_dq[4]] ;# SO_DQ4
set_property PACKAGE_PIN AC2 [get_ports ddr3_dq[5]] ;# SO_DQ5
set_property PACKAGE_PIN AD3 [get_ports ddr3_dq[6]] ;# SO_DQ6
set_property PACKAGE_PIN AC7 [get_ports ddr3_dq[7]] ;# SO_DQ7
set_property PACKAGE_PIN AE5 [get_ports ddr3_dq[8]] ;# SO_DQ8
set_property PACKAGE_PIN AE4 [get_ports ddr3_dq[9]] ;# SO_DQ9
set_property PACKAGE_PIN AF5 [get_ports ddr3_dq[10]] ;# SO_DQ10
set_property PACKAGE_PIN AF6 [get_ports ddr3_dq[11]] ;# SO_DQ11
set_property PACKAGE_PIN AE3 [get_ports ddr3_dq[12]] ;# SO_DQ12
set_property PACKAGE_PIN AF3 [get_ports ddr3_dq[13]] ;# SO_DQ13
set_property PACKAGE_PIN AF1 [get_ports ddr3_dq[14]] ;# SO_DQ14
set_property PACKAGE_PIN AF2 [get_ports ddr3_dq[15]] ;# SO_DQ15
set_property PACKAGE_PIN AH5 [get_ports ddr3_dq[16]] ;# SO_DQ16
set_property PACKAGE_PIN AH6 [get_ports ddr3_dq[17]] ;# SO_DQ17
set_property PACKAGE_PIN AK3 [get_ports ddr3_dq[18]] ;# SO_DQ18
set_property PACKAGE_PIN AJ4 [get_ports ddr3_dq[19]] ;# SO_DQ19
set_property PACKAGE_PIN AJ1 [get_ports ddr3_dq[20]] ;# SO_DQ20
set_property PACKAGE_PIN AK1 [get_ports ddr3_dq[21]] ;# SO_DQ21
set_property PACKAGE_PIN AJ2 [get_ports ddr3_dq[22]] ;# SO_DQ22
set_property PACKAGE_PIN AJ3 [get_ports ddr3_dq[23]] ;# SO_DQ23
set_property PACKAGE_PIN AK4 [get_ports ddr3_dq[24]] ;# SO_DQ24
set_property PACKAGE_PIN AK5 [get_ports ddr3_dq[25]] ;# SO_DQ25
set_property PACKAGE_PIN AJ6 [get_ports ddr3_dq[26]] ;# SO_DQ26
set_property PACKAGE_PIN AK6 [get_ports ddr3_dq[27]] ;# SO_DQ27
set_property PACKAGE_PIN AF7 [get_ports ddr3_dq[28]] ;# SO_DQ28
set_property PACKAGE_PIN AF8 [get_ports ddr3_dq[29]] ;# SO_DQ29
set_property PACKAGE_PIN AJ8 [get_ports ddr3_dq[30]] ;# SO_DQ30
set_property PACKAGE_PIN AK8 [get_ports ddr3_dq[31]] ;# SO_DQ31
set_property PACKAGE_PIN AH12 [get_ports ddr3_dq[32]] ;# SO_DQ32
set_property PACKAGE_PIN AG13 [get_ports ddr3_dq[33]] ;# SO_DQ33
set_property PACKAGE_PIN AF12 [get_ports ddr3_dq[34]] ;# SO_DQ34
set_property PACKAGE_PIN AE13 [get_ports ddr3_dq[35]] ;# SO_DQ35
set_property PACKAGE_PIN AJ12 [get_ports ddr3_dq[36]] ;# SO_DQ36
set_property PACKAGE_PIN AJ13 [get_ports ddr3_dq[37]] ;# SO_DQ37
set_property PACKAGE_PIN AK14 [get_ports ddr3_dq[38]] ;# SO_DQ38
set_property PACKAGE_PIN AG12 [get_ports ddr3_dq[39]] ;# SO_DQ39
set_property PACKAGE_PIN AG14 [get_ports ddr3_dq[40]] ;# SO_DQ40
set_property PACKAGE_PIN AH15 [get_ports ddr3_dq[41]] ;# SO_DQ41
set_property PACKAGE_PIN AF15 [get_ports ddr3_dq[42]] ;# SO_DQ42
set_property PACKAGE_PIN AE16 [get_ports ddr3_dq[43]] ;# SO_DQ43
set_property PACKAGE_PIN AK15 [get_ports ddr3_dq[44]] ;# SO_DQ44
set_property PACKAGE_PIN AK16 [get_ports ddr3_dq[45]] ;# SO_DQ45
set_property PACKAGE_PIN AJ17 [get_ports ddr3_dq[46]] ;# SO_DQ46
set_property PACKAGE_PIN AH17 [get_ports ddr3_dq[47]] ;# SO_DQ47
set_property PACKAGE_PIN AF18 [get_ports ddr3_dq[48]] ;# SO_DQ48
set_property PACKAGE_PIN AG19 [get_ports ddr3_dq[49]] ;# SO_DQ49
set_property PACKAGE_PIN AE19 [get_ports ddr3_dq[50]] ;# SO_DQ50
set_property PACKAGE_PIN AD19 [get_ports ddr3_dq[51]] ;# SO_DQ51
set_property PACKAGE_PIN AF17 [get_ports ddr3_dq[52]] ;# SO_DQ52
set_property PACKAGE_PIN AG18 [get_ports ddr3_dq[53]] ;# SO_DQ53
set_property PACKAGE_PIN AJ19 [get_ports ddr3_dq[54]] ;# SO_DQ54
set_property PACKAGE_PIN AH19 [get_ports ddr3_dq[55]] ;# SO_DQ55
set_property PACKAGE_PIN AB17 [get_ports ddr3_dq[56]] ;# SO_DQ56
set_property PACKAGE_PIN AC19 [get_ports ddr3_dq[57]] ;# SO_DQ57
set_property PACKAGE_PIN AB18 [get_ports ddr3_dq[58]] ;# SO_DQ58
set_property PACKAGE_PIN AA18 [get_ports ddr3_dq[59]] ;# SO_DQ59
set_property PACKAGE_PIN AD16 [get_ports ddr3_dq[60]] ;# SO_DQ60
set_property PACKAGE_PIN AD17 [get_ports ddr3_dq[61]] ;# SO_DQ61
set_property PACKAGE_PIN AE18 [get_ports ddr3_dq[62]] ;# SO_DQ62
set_property PACKAGE_PIN AD18 [get_ports ddr3_dq[63]] ;# SO_DQ63
set_property PACKAGE_PIN AD1 [get_ports ddr3_dqs_n[0]] ;# SO_DQS0_N
set_property PACKAGE_PIN AG3 [get_ports ddr3_dqs_n[1]] ;# SO_DQS1_N
set_property PACKAGE_PIN AH1 [get_ports ddr3_dqs_n[2]] ;# SO_DQS2_N
set_property PACKAGE_PIN AJ7 [get_ports ddr3_dqs_n[3]] ;# SO_DQS3_N
set_property PACKAGE_PIN AJ14 [get_ports ddr3_dqs_n[4]] ;# SO_DQS4_N
set_property PACKAGE_PIN AJ16 [get_ports ddr3_dqs_n[5]] ;# SO_DQS5_N
set_property PACKAGE_PIN AK18 [get_ports ddr3_dqs_n[6]] ;# SO_DQS6_N
set_property PACKAGE_PIN Y18 [get_ports ddr3_dqs_n[7]] ;# SO_DQS7_N
set_property PACKAGE_PIN AD2 [get_ports ddr3_dqs_p[0]] ;# SO_DQS0_P
set_property PACKAGE_PIN AG4 [get_ports ddr3_dqs_p[1]] ;# SO_DQS1_P
set_property PACKAGE_PIN AG2 [get_ports ddr3_dqs_p[2]] ;# SO_DQS2_P
set_property PACKAGE_PIN AH7 [get_ports ddr3_dqs_p[3]] ;# SO_DQS3_P
set_property PACKAGE_PIN AH14 [get_ports ddr3_dqs_p[4]] ;# SO_DQS4_P
set_property PACKAGE_PIN AH16 [get_ports ddr3_dqs_p[5]] ;# SO_DQS5_P
set_property PACKAGE_PIN AJ18 [get_ports ddr3_dqs_p[6]] ;# SO_DQS6_P
set_property -dict {PACKAGE_PIN AA28 IOSTANDARD LVCMOS33} [get_ports sodimm_i2c_scl] ;# SO_I2C_SCL
set_property -dict {PACKAGE_PIN AB28 IOSTANDARD LVCMOS33} [get_ports sodimm_i2c_sda] ;# SO_I2C_SDA
set_property PACKAGE_PIN Y19 [get_ports ddr3_dqs_p[7]] ;# SO_DQS7_P
set_property PACKAGE_PIN AJ11 [get_ports ddr3_odt[0]] ;# SO_ODT0
set_property PACKAGE_PIN AK11 [get_ports ddr3_odt[1]] ;# SO_ODT1
set_property PACKAGE_PIN AA12 [get_ports ddr3_ras_n] ;# SO_RAS#
set_property PACKAGE_PIN AG5 [get_ports ddr3_reset_n] ;# SO_RESET_B
set_property PACKAGE_PIN AC11 [get_ports ddr3_we_n] ;# SO_WE#
set_property PACKAGE_PIN AG17 [get_ports sodimm_event_n] ;# SO_EVENT_B

# SFP+ 0 (MGT_3_115)
set_property PACKAGE_PIN K14 [get_ports {sfp_rx_los[0]}]
set_property PACKAGE_PIN K15 [get_ports {sfp_tx_dis[0]}]
set_property PACKAGE_PIN V5 [get_ports {sfp_rx_n[0]}]
set_property PACKAGE_PIN V6 [get_ports {sfp_rx_p[0]}]
set_property PACKAGE_PIN T1 [get_ports {sfp_tx_n[0]}]
set_property PACKAGE_PIN T2 [get_ports {sfp_tx_p[0]}]

# SFP+ 1 (MGT_0_115)
set_property PACKAGE_PIN L15 [get_ports {sfp_rx_los[1]}]
set_property PACKAGE_PIN J14 [get_ports {sfp_tx_dis[1]}]
set_property PACKAGE_PIN AA3 [get_ports {sfp_rx_n[1]}]
set_property PACKAGE_PIN AA4 [get_ports {sfp_rx_p[1]}]
set_property PACKAGE_PIN Y1 [get_ports {sfp_tx_n[1]}]
set_property PACKAGE_PIN Y2 [get_ports {sfp_tx_p[1]}]

# SFP+ 2 (MGT_1_115)
set_property PACKAGE_PIN L12 [get_ports {sfp_rx_los[2]}]
set_property PACKAGE_PIN J13 [get_ports {sfp_tx_dis[2]}]
set_property PACKAGE_PIN Y5 [get_ports {sfp_rx_n[2]}]
set_property PACKAGE_PIN Y6 [get_ports {sfp_rx_p[2]}]
set_property PACKAGE_PIN V1 [get_ports {sfp_tx_n[2]}]
set_property PACKAGE_PIN V2 [get_ports {sfp_tx_p[2]}]

# SFP+ 3 (MGT_2_115)
set_property PACKAGE_PIN K13 [get_ports {sfp_rx_los[3]}]
set_property PACKAGE_PIN J12 [get_ports {sfp_tx_dis[3]}]
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

set_property IOSTANDARD LVCMOS33 [get_ports {sfp_rx_los[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_tx_dis[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_link[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_act[*]}]

set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports sfp_scl] ;# SFP_SCL
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports sfp_sda] ;# SFP_SDA

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Input/Output Delay for SRAM.
# Make sure that input delay + output delay - 10 == clock period
set_input_delay -clock ram_clk_out_clk_wiz_0 -max 20.000 [get_ports {base_ram_data[*]}]
set_output_delay -clock ram_clk_out_clk_wiz_0 -max 15.000 [get_ports {base_ram_data[*]}]
set_output_delay -clock ram_clk_out_clk_wiz_0 -max 15.000 [get_ports {base_ram_addr[*]}]
set_output_delay -clock ram_clk_out_clk_wiz_0 -max 15.000 [get_ports {base_ram_be_n[*]}]
set_output_delay -clock ram_clk_out_clk_wiz_0 -max 15.000 [get_ports base_ram_ce_n]
set_output_delay -clock ram_clk_out_clk_wiz_0 -max 15.000 [get_ports base_ram_oe_n]
set_output_delay -clock ram_clk_out_clk_wiz_0 -max 15.000 [get_ports base_ram_we_n]

set_false_path -from [get_pins clk_wiz_0_i/inst/mmcm_adv_inst/CLKOUT2] -to [get_ports base_ram_we_n]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list u_mig_7series_0/u_mig_7series_0_mig/u_ddr3_infrastructure/CLK]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {app_cmd[0]} {app_cmd[1]} {app_cmd[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 29 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {app_addr[0]} {app_addr[1]} {app_addr[2]} {app_addr[3]} {app_addr[4]} {app_addr[5]} {app_addr[6]} {app_addr[7]} {app_addr[8]} {app_addr[9]} {app_addr[10]} {app_addr[11]} {app_addr[12]} {app_addr[13]} {app_addr[14]} {app_addr[15]} {app_addr[16]} {app_addr[17]} {app_addr[18]} {app_addr[19]} {app_addr[20]} {app_addr[21]} {app_addr[22]} {app_addr[23]} {app_addr[24]} {app_addr[25]} {app_addr[26]} {app_addr[27]} {app_addr[28]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 512 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {app_wdf_data[0]} {app_wdf_data[1]} {app_wdf_data[2]} {app_wdf_data[3]} {app_wdf_data[4]} {app_wdf_data[5]} {app_wdf_data[6]} {app_wdf_data[7]} {app_wdf_data[8]} {app_wdf_data[9]} {app_wdf_data[10]} {app_wdf_data[11]} {app_wdf_data[12]} {app_wdf_data[13]} {app_wdf_data[14]} {app_wdf_data[15]} {app_wdf_data[16]} {app_wdf_data[17]} {app_wdf_data[18]} {app_wdf_data[19]} {app_wdf_data[20]} {app_wdf_data[21]} {app_wdf_data[22]} {app_wdf_data[23]} {app_wdf_data[24]} {app_wdf_data[25]} {app_wdf_data[26]} {app_wdf_data[27]} {app_wdf_data[28]} {app_wdf_data[29]} {app_wdf_data[30]} {app_wdf_data[31]} {app_wdf_data[32]} {app_wdf_data[33]} {app_wdf_data[34]} {app_wdf_data[35]} {app_wdf_data[36]} {app_wdf_data[37]} {app_wdf_data[38]} {app_wdf_data[39]} {app_wdf_data[40]} {app_wdf_data[41]} {app_wdf_data[42]} {app_wdf_data[43]} {app_wdf_data[44]} {app_wdf_data[45]} {app_wdf_data[46]} {app_wdf_data[47]} {app_wdf_data[48]} {app_wdf_data[49]} {app_wdf_data[50]} {app_wdf_data[51]} {app_wdf_data[52]} {app_wdf_data[53]} {app_wdf_data[54]} {app_wdf_data[55]} {app_wdf_data[56]} {app_wdf_data[57]} {app_wdf_data[58]} {app_wdf_data[59]} {app_wdf_data[60]} {app_wdf_data[61]} {app_wdf_data[62]} {app_wdf_data[63]} {app_wdf_data[64]} {app_wdf_data[65]} {app_wdf_data[66]} {app_wdf_data[67]} {app_wdf_data[68]} {app_wdf_data[69]} {app_wdf_data[70]} {app_wdf_data[71]} {app_wdf_data[72]} {app_wdf_data[73]} {app_wdf_data[74]} {app_wdf_data[75]} {app_wdf_data[76]} {app_wdf_data[77]} {app_wdf_data[78]} {app_wdf_data[79]} {app_wdf_data[80]} {app_wdf_data[81]} {app_wdf_data[82]} {app_wdf_data[83]} {app_wdf_data[84]} {app_wdf_data[85]} {app_wdf_data[86]} {app_wdf_data[87]} {app_wdf_data[88]} {app_wdf_data[89]} {app_wdf_data[90]} {app_wdf_data[91]} {app_wdf_data[92]} {app_wdf_data[93]} {app_wdf_data[94]} {app_wdf_data[95]} {app_wdf_data[96]} {app_wdf_data[97]} {app_wdf_data[98]} {app_wdf_data[99]} {app_wdf_data[100]} {app_wdf_data[101]} {app_wdf_data[102]} {app_wdf_data[103]} {app_wdf_data[104]} {app_wdf_data[105]} {app_wdf_data[106]} {app_wdf_data[107]} {app_wdf_data[108]} {app_wdf_data[109]} {app_wdf_data[110]} {app_wdf_data[111]} {app_wdf_data[112]} {app_wdf_data[113]} {app_wdf_data[114]} {app_wdf_data[115]} {app_wdf_data[116]} {app_wdf_data[117]} {app_wdf_data[118]} {app_wdf_data[119]} {app_wdf_data[120]} {app_wdf_data[121]} {app_wdf_data[122]} {app_wdf_data[123]} {app_wdf_data[124]} {app_wdf_data[125]} {app_wdf_data[126]} {app_wdf_data[127]} {app_wdf_data[128]} {app_wdf_data[129]} {app_wdf_data[130]} {app_wdf_data[131]} {app_wdf_data[132]} {app_wdf_data[133]} {app_wdf_data[134]} {app_wdf_data[135]} {app_wdf_data[136]} {app_wdf_data[137]} {app_wdf_data[138]} {app_wdf_data[139]} {app_wdf_data[140]} {app_wdf_data[141]} {app_wdf_data[142]} {app_wdf_data[143]} {app_wdf_data[144]} {app_wdf_data[145]} {app_wdf_data[146]} {app_wdf_data[147]} {app_wdf_data[148]} {app_wdf_data[149]} {app_wdf_data[150]} {app_wdf_data[151]} {app_wdf_data[152]} {app_wdf_data[153]} {app_wdf_data[154]} {app_wdf_data[155]} {app_wdf_data[156]} {app_wdf_data[157]} {app_wdf_data[158]} {app_wdf_data[159]} {app_wdf_data[160]} {app_wdf_data[161]} {app_wdf_data[162]} {app_wdf_data[163]} {app_wdf_data[164]} {app_wdf_data[165]} {app_wdf_data[166]} {app_wdf_data[167]} {app_wdf_data[168]} {app_wdf_data[169]} {app_wdf_data[170]} {app_wdf_data[171]} {app_wdf_data[172]} {app_wdf_data[173]} {app_wdf_data[174]} {app_wdf_data[175]} {app_wdf_data[176]} {app_wdf_data[177]} {app_wdf_data[178]} {app_wdf_data[179]} {app_wdf_data[180]} {app_wdf_data[181]} {app_wdf_data[182]} {app_wdf_data[183]} {app_wdf_data[184]} {app_wdf_data[185]} {app_wdf_data[186]} {app_wdf_data[187]} {app_wdf_data[188]} {app_wdf_data[189]} {app_wdf_data[190]} {app_wdf_data[191]} {app_wdf_data[192]} {app_wdf_data[193]} {app_wdf_data[194]} {app_wdf_data[195]} {app_wdf_data[196]} {app_wdf_data[197]} {app_wdf_data[198]} {app_wdf_data[199]} {app_wdf_data[200]} {app_wdf_data[201]} {app_wdf_data[202]} {app_wdf_data[203]} {app_wdf_data[204]} {app_wdf_data[205]} {app_wdf_data[206]} {app_wdf_data[207]} {app_wdf_data[208]} {app_wdf_data[209]} {app_wdf_data[210]} {app_wdf_data[211]} {app_wdf_data[212]} {app_wdf_data[213]} {app_wdf_data[214]} {app_wdf_data[215]} {app_wdf_data[216]} {app_wdf_data[217]} {app_wdf_data[218]} {app_wdf_data[219]} {app_wdf_data[220]} {app_wdf_data[221]} {app_wdf_data[222]} {app_wdf_data[223]} {app_wdf_data[224]} {app_wdf_data[225]} {app_wdf_data[226]} {app_wdf_data[227]} {app_wdf_data[228]} {app_wdf_data[229]} {app_wdf_data[230]} {app_wdf_data[231]} {app_wdf_data[232]} {app_wdf_data[233]} {app_wdf_data[234]} {app_wdf_data[235]} {app_wdf_data[236]} {app_wdf_data[237]} {app_wdf_data[238]} {app_wdf_data[239]} {app_wdf_data[240]} {app_wdf_data[241]} {app_wdf_data[242]} {app_wdf_data[243]} {app_wdf_data[244]} {app_wdf_data[245]} {app_wdf_data[246]} {app_wdf_data[247]} {app_wdf_data[248]} {app_wdf_data[249]} {app_wdf_data[250]} {app_wdf_data[251]} {app_wdf_data[252]} {app_wdf_data[253]} {app_wdf_data[254]} {app_wdf_data[255]} {app_wdf_data[256]} {app_wdf_data[257]} {app_wdf_data[258]} {app_wdf_data[259]} {app_wdf_data[260]} {app_wdf_data[261]} {app_wdf_data[262]} {app_wdf_data[263]} {app_wdf_data[264]} {app_wdf_data[265]} {app_wdf_data[266]} {app_wdf_data[267]} {app_wdf_data[268]} {app_wdf_data[269]} {app_wdf_data[270]} {app_wdf_data[271]} {app_wdf_data[272]} {app_wdf_data[273]} {app_wdf_data[274]} {app_wdf_data[275]} {app_wdf_data[276]} {app_wdf_data[277]} {app_wdf_data[278]} {app_wdf_data[279]} {app_wdf_data[280]} {app_wdf_data[281]} {app_wdf_data[282]} {app_wdf_data[283]} {app_wdf_data[284]} {app_wdf_data[285]} {app_wdf_data[286]} {app_wdf_data[287]} {app_wdf_data[288]} {app_wdf_data[289]} {app_wdf_data[290]} {app_wdf_data[291]} {app_wdf_data[292]} {app_wdf_data[293]} {app_wdf_data[294]} {app_wdf_data[295]} {app_wdf_data[296]} {app_wdf_data[297]} {app_wdf_data[298]} {app_wdf_data[299]} {app_wdf_data[300]} {app_wdf_data[301]} {app_wdf_data[302]} {app_wdf_data[303]} {app_wdf_data[304]} {app_wdf_data[305]} {app_wdf_data[306]} {app_wdf_data[307]} {app_wdf_data[308]} {app_wdf_data[309]} {app_wdf_data[310]} {app_wdf_data[311]} {app_wdf_data[312]} {app_wdf_data[313]} {app_wdf_data[314]} {app_wdf_data[315]} {app_wdf_data[316]} {app_wdf_data[317]} {app_wdf_data[318]} {app_wdf_data[319]} {app_wdf_data[320]} {app_wdf_data[321]} {app_wdf_data[322]} {app_wdf_data[323]} {app_wdf_data[324]} {app_wdf_data[325]} {app_wdf_data[326]} {app_wdf_data[327]} {app_wdf_data[328]} {app_wdf_data[329]} {app_wdf_data[330]} {app_wdf_data[331]} {app_wdf_data[332]} {app_wdf_data[333]} {app_wdf_data[334]} {app_wdf_data[335]} {app_wdf_data[336]} {app_wdf_data[337]} {app_wdf_data[338]} {app_wdf_data[339]} {app_wdf_data[340]} {app_wdf_data[341]} {app_wdf_data[342]} {app_wdf_data[343]} {app_wdf_data[344]} {app_wdf_data[345]} {app_wdf_data[346]} {app_wdf_data[347]} {app_wdf_data[348]} {app_wdf_data[349]} {app_wdf_data[350]} {app_wdf_data[351]} {app_wdf_data[352]} {app_wdf_data[353]} {app_wdf_data[354]} {app_wdf_data[355]} {app_wdf_data[356]} {app_wdf_data[357]} {app_wdf_data[358]} {app_wdf_data[359]} {app_wdf_data[360]} {app_wdf_data[361]} {app_wdf_data[362]} {app_wdf_data[363]} {app_wdf_data[364]} {app_wdf_data[365]} {app_wdf_data[366]} {app_wdf_data[367]} {app_wdf_data[368]} {app_wdf_data[369]} {app_wdf_data[370]} {app_wdf_data[371]} {app_wdf_data[372]} {app_wdf_data[373]} {app_wdf_data[374]} {app_wdf_data[375]} {app_wdf_data[376]} {app_wdf_data[377]} {app_wdf_data[378]} {app_wdf_data[379]} {app_wdf_data[380]} {app_wdf_data[381]} {app_wdf_data[382]} {app_wdf_data[383]} {app_wdf_data[384]} {app_wdf_data[385]} {app_wdf_data[386]} {app_wdf_data[387]} {app_wdf_data[388]} {app_wdf_data[389]} {app_wdf_data[390]} {app_wdf_data[391]} {app_wdf_data[392]} {app_wdf_data[393]} {app_wdf_data[394]} {app_wdf_data[395]} {app_wdf_data[396]} {app_wdf_data[397]} {app_wdf_data[398]} {app_wdf_data[399]} {app_wdf_data[400]} {app_wdf_data[401]} {app_wdf_data[402]} {app_wdf_data[403]} {app_wdf_data[404]} {app_wdf_data[405]} {app_wdf_data[406]} {app_wdf_data[407]} {app_wdf_data[408]} {app_wdf_data[409]} {app_wdf_data[410]} {app_wdf_data[411]} {app_wdf_data[412]} {app_wdf_data[413]} {app_wdf_data[414]} {app_wdf_data[415]} {app_wdf_data[416]} {app_wdf_data[417]} {app_wdf_data[418]} {app_wdf_data[419]} {app_wdf_data[420]} {app_wdf_data[421]} {app_wdf_data[422]} {app_wdf_data[423]} {app_wdf_data[424]} {app_wdf_data[425]} {app_wdf_data[426]} {app_wdf_data[427]} {app_wdf_data[428]} {app_wdf_data[429]} {app_wdf_data[430]} {app_wdf_data[431]} {app_wdf_data[432]} {app_wdf_data[433]} {app_wdf_data[434]} {app_wdf_data[435]} {app_wdf_data[436]} {app_wdf_data[437]} {app_wdf_data[438]} {app_wdf_data[439]} {app_wdf_data[440]} {app_wdf_data[441]} {app_wdf_data[442]} {app_wdf_data[443]} {app_wdf_data[444]} {app_wdf_data[445]} {app_wdf_data[446]} {app_wdf_data[447]} {app_wdf_data[448]} {app_wdf_data[449]} {app_wdf_data[450]} {app_wdf_data[451]} {app_wdf_data[452]} {app_wdf_data[453]} {app_wdf_data[454]} {app_wdf_data[455]} {app_wdf_data[456]} {app_wdf_data[457]} {app_wdf_data[458]} {app_wdf_data[459]} {app_wdf_data[460]} {app_wdf_data[461]} {app_wdf_data[462]} {app_wdf_data[463]} {app_wdf_data[464]} {app_wdf_data[465]} {app_wdf_data[466]} {app_wdf_data[467]} {app_wdf_data[468]} {app_wdf_data[469]} {app_wdf_data[470]} {app_wdf_data[471]} {app_wdf_data[472]} {app_wdf_data[473]} {app_wdf_data[474]} {app_wdf_data[475]} {app_wdf_data[476]} {app_wdf_data[477]} {app_wdf_data[478]} {app_wdf_data[479]} {app_wdf_data[480]} {app_wdf_data[481]} {app_wdf_data[482]} {app_wdf_data[483]} {app_wdf_data[484]} {app_wdf_data[485]} {app_wdf_data[486]} {app_wdf_data[487]} {app_wdf_data[488]} {app_wdf_data[489]} {app_wdf_data[490]} {app_wdf_data[491]} {app_wdf_data[492]} {app_wdf_data[493]} {app_wdf_data[494]} {app_wdf_data[495]} {app_wdf_data[496]} {app_wdf_data[497]} {app_wdf_data[498]} {app_wdf_data[499]} {app_wdf_data[500]} {app_wdf_data[501]} {app_wdf_data[502]} {app_wdf_data[503]} {app_wdf_data[504]} {app_wdf_data[505]} {app_wdf_data[506]} {app_wdf_data[507]} {app_wdf_data[508]} {app_wdf_data[509]} {app_wdf_data[510]} {app_wdf_data[511]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 512 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {app_rd_data[0]} {app_rd_data[1]} {app_rd_data[2]} {app_rd_data[3]} {app_rd_data[4]} {app_rd_data[5]} {app_rd_data[6]} {app_rd_data[7]} {app_rd_data[8]} {app_rd_data[9]} {app_rd_data[10]} {app_rd_data[11]} {app_rd_data[12]} {app_rd_data[13]} {app_rd_data[14]} {app_rd_data[15]} {app_rd_data[16]} {app_rd_data[17]} {app_rd_data[18]} {app_rd_data[19]} {app_rd_data[20]} {app_rd_data[21]} {app_rd_data[22]} {app_rd_data[23]} {app_rd_data[24]} {app_rd_data[25]} {app_rd_data[26]} {app_rd_data[27]} {app_rd_data[28]} {app_rd_data[29]} {app_rd_data[30]} {app_rd_data[31]} {app_rd_data[32]} {app_rd_data[33]} {app_rd_data[34]} {app_rd_data[35]} {app_rd_data[36]} {app_rd_data[37]} {app_rd_data[38]} {app_rd_data[39]} {app_rd_data[40]} {app_rd_data[41]} {app_rd_data[42]} {app_rd_data[43]} {app_rd_data[44]} {app_rd_data[45]} {app_rd_data[46]} {app_rd_data[47]} {app_rd_data[48]} {app_rd_data[49]} {app_rd_data[50]} {app_rd_data[51]} {app_rd_data[52]} {app_rd_data[53]} {app_rd_data[54]} {app_rd_data[55]} {app_rd_data[56]} {app_rd_data[57]} {app_rd_data[58]} {app_rd_data[59]} {app_rd_data[60]} {app_rd_data[61]} {app_rd_data[62]} {app_rd_data[63]} {app_rd_data[64]} {app_rd_data[65]} {app_rd_data[66]} {app_rd_data[67]} {app_rd_data[68]} {app_rd_data[69]} {app_rd_data[70]} {app_rd_data[71]} {app_rd_data[72]} {app_rd_data[73]} {app_rd_data[74]} {app_rd_data[75]} {app_rd_data[76]} {app_rd_data[77]} {app_rd_data[78]} {app_rd_data[79]} {app_rd_data[80]} {app_rd_data[81]} {app_rd_data[82]} {app_rd_data[83]} {app_rd_data[84]} {app_rd_data[85]} {app_rd_data[86]} {app_rd_data[87]} {app_rd_data[88]} {app_rd_data[89]} {app_rd_data[90]} {app_rd_data[91]} {app_rd_data[92]} {app_rd_data[93]} {app_rd_data[94]} {app_rd_data[95]} {app_rd_data[96]} {app_rd_data[97]} {app_rd_data[98]} {app_rd_data[99]} {app_rd_data[100]} {app_rd_data[101]} {app_rd_data[102]} {app_rd_data[103]} {app_rd_data[104]} {app_rd_data[105]} {app_rd_data[106]} {app_rd_data[107]} {app_rd_data[108]} {app_rd_data[109]} {app_rd_data[110]} {app_rd_data[111]} {app_rd_data[112]} {app_rd_data[113]} {app_rd_data[114]} {app_rd_data[115]} {app_rd_data[116]} {app_rd_data[117]} {app_rd_data[118]} {app_rd_data[119]} {app_rd_data[120]} {app_rd_data[121]} {app_rd_data[122]} {app_rd_data[123]} {app_rd_data[124]} {app_rd_data[125]} {app_rd_data[126]} {app_rd_data[127]} {app_rd_data[128]} {app_rd_data[129]} {app_rd_data[130]} {app_rd_data[131]} {app_rd_data[132]} {app_rd_data[133]} {app_rd_data[134]} {app_rd_data[135]} {app_rd_data[136]} {app_rd_data[137]} {app_rd_data[138]} {app_rd_data[139]} {app_rd_data[140]} {app_rd_data[141]} {app_rd_data[142]} {app_rd_data[143]} {app_rd_data[144]} {app_rd_data[145]} {app_rd_data[146]} {app_rd_data[147]} {app_rd_data[148]} {app_rd_data[149]} {app_rd_data[150]} {app_rd_data[151]} {app_rd_data[152]} {app_rd_data[153]} {app_rd_data[154]} {app_rd_data[155]} {app_rd_data[156]} {app_rd_data[157]} {app_rd_data[158]} {app_rd_data[159]} {app_rd_data[160]} {app_rd_data[161]} {app_rd_data[162]} {app_rd_data[163]} {app_rd_data[164]} {app_rd_data[165]} {app_rd_data[166]} {app_rd_data[167]} {app_rd_data[168]} {app_rd_data[169]} {app_rd_data[170]} {app_rd_data[171]} {app_rd_data[172]} {app_rd_data[173]} {app_rd_data[174]} {app_rd_data[175]} {app_rd_data[176]} {app_rd_data[177]} {app_rd_data[178]} {app_rd_data[179]} {app_rd_data[180]} {app_rd_data[181]} {app_rd_data[182]} {app_rd_data[183]} {app_rd_data[184]} {app_rd_data[185]} {app_rd_data[186]} {app_rd_data[187]} {app_rd_data[188]} {app_rd_data[189]} {app_rd_data[190]} {app_rd_data[191]} {app_rd_data[192]} {app_rd_data[193]} {app_rd_data[194]} {app_rd_data[195]} {app_rd_data[196]} {app_rd_data[197]} {app_rd_data[198]} {app_rd_data[199]} {app_rd_data[200]} {app_rd_data[201]} {app_rd_data[202]} {app_rd_data[203]} {app_rd_data[204]} {app_rd_data[205]} {app_rd_data[206]} {app_rd_data[207]} {app_rd_data[208]} {app_rd_data[209]} {app_rd_data[210]} {app_rd_data[211]} {app_rd_data[212]} {app_rd_data[213]} {app_rd_data[214]} {app_rd_data[215]} {app_rd_data[216]} {app_rd_data[217]} {app_rd_data[218]} {app_rd_data[219]} {app_rd_data[220]} {app_rd_data[221]} {app_rd_data[222]} {app_rd_data[223]} {app_rd_data[224]} {app_rd_data[225]} {app_rd_data[226]} {app_rd_data[227]} {app_rd_data[228]} {app_rd_data[229]} {app_rd_data[230]} {app_rd_data[231]} {app_rd_data[232]} {app_rd_data[233]} {app_rd_data[234]} {app_rd_data[235]} {app_rd_data[236]} {app_rd_data[237]} {app_rd_data[238]} {app_rd_data[239]} {app_rd_data[240]} {app_rd_data[241]} {app_rd_data[242]} {app_rd_data[243]} {app_rd_data[244]} {app_rd_data[245]} {app_rd_data[246]} {app_rd_data[247]} {app_rd_data[248]} {app_rd_data[249]} {app_rd_data[250]} {app_rd_data[251]} {app_rd_data[252]} {app_rd_data[253]} {app_rd_data[254]} {app_rd_data[255]} {app_rd_data[256]} {app_rd_data[257]} {app_rd_data[258]} {app_rd_data[259]} {app_rd_data[260]} {app_rd_data[261]} {app_rd_data[262]} {app_rd_data[263]} {app_rd_data[264]} {app_rd_data[265]} {app_rd_data[266]} {app_rd_data[267]} {app_rd_data[268]} {app_rd_data[269]} {app_rd_data[270]} {app_rd_data[271]} {app_rd_data[272]} {app_rd_data[273]} {app_rd_data[274]} {app_rd_data[275]} {app_rd_data[276]} {app_rd_data[277]} {app_rd_data[278]} {app_rd_data[279]} {app_rd_data[280]} {app_rd_data[281]} {app_rd_data[282]} {app_rd_data[283]} {app_rd_data[284]} {app_rd_data[285]} {app_rd_data[286]} {app_rd_data[287]} {app_rd_data[288]} {app_rd_data[289]} {app_rd_data[290]} {app_rd_data[291]} {app_rd_data[292]} {app_rd_data[293]} {app_rd_data[294]} {app_rd_data[295]} {app_rd_data[296]} {app_rd_data[297]} {app_rd_data[298]} {app_rd_data[299]} {app_rd_data[300]} {app_rd_data[301]} {app_rd_data[302]} {app_rd_data[303]} {app_rd_data[304]} {app_rd_data[305]} {app_rd_data[306]} {app_rd_data[307]} {app_rd_data[308]} {app_rd_data[309]} {app_rd_data[310]} {app_rd_data[311]} {app_rd_data[312]} {app_rd_data[313]} {app_rd_data[314]} {app_rd_data[315]} {app_rd_data[316]} {app_rd_data[317]} {app_rd_data[318]} {app_rd_data[319]} {app_rd_data[320]} {app_rd_data[321]} {app_rd_data[322]} {app_rd_data[323]} {app_rd_data[324]} {app_rd_data[325]} {app_rd_data[326]} {app_rd_data[327]} {app_rd_data[328]} {app_rd_data[329]} {app_rd_data[330]} {app_rd_data[331]} {app_rd_data[332]} {app_rd_data[333]} {app_rd_data[334]} {app_rd_data[335]} {app_rd_data[336]} {app_rd_data[337]} {app_rd_data[338]} {app_rd_data[339]} {app_rd_data[340]} {app_rd_data[341]} {app_rd_data[342]} {app_rd_data[343]} {app_rd_data[344]} {app_rd_data[345]} {app_rd_data[346]} {app_rd_data[347]} {app_rd_data[348]} {app_rd_data[349]} {app_rd_data[350]} {app_rd_data[351]} {app_rd_data[352]} {app_rd_data[353]} {app_rd_data[354]} {app_rd_data[355]} {app_rd_data[356]} {app_rd_data[357]} {app_rd_data[358]} {app_rd_data[359]} {app_rd_data[360]} {app_rd_data[361]} {app_rd_data[362]} {app_rd_data[363]} {app_rd_data[364]} {app_rd_data[365]} {app_rd_data[366]} {app_rd_data[367]} {app_rd_data[368]} {app_rd_data[369]} {app_rd_data[370]} {app_rd_data[371]} {app_rd_data[372]} {app_rd_data[373]} {app_rd_data[374]} {app_rd_data[375]} {app_rd_data[376]} {app_rd_data[377]} {app_rd_data[378]} {app_rd_data[379]} {app_rd_data[380]} {app_rd_data[381]} {app_rd_data[382]} {app_rd_data[383]} {app_rd_data[384]} {app_rd_data[385]} {app_rd_data[386]} {app_rd_data[387]} {app_rd_data[388]} {app_rd_data[389]} {app_rd_data[390]} {app_rd_data[391]} {app_rd_data[392]} {app_rd_data[393]} {app_rd_data[394]} {app_rd_data[395]} {app_rd_data[396]} {app_rd_data[397]} {app_rd_data[398]} {app_rd_data[399]} {app_rd_data[400]} {app_rd_data[401]} {app_rd_data[402]} {app_rd_data[403]} {app_rd_data[404]} {app_rd_data[405]} {app_rd_data[406]} {app_rd_data[407]} {app_rd_data[408]} {app_rd_data[409]} {app_rd_data[410]} {app_rd_data[411]} {app_rd_data[412]} {app_rd_data[413]} {app_rd_data[414]} {app_rd_data[415]} {app_rd_data[416]} {app_rd_data[417]} {app_rd_data[418]} {app_rd_data[419]} {app_rd_data[420]} {app_rd_data[421]} {app_rd_data[422]} {app_rd_data[423]} {app_rd_data[424]} {app_rd_data[425]} {app_rd_data[426]} {app_rd_data[427]} {app_rd_data[428]} {app_rd_data[429]} {app_rd_data[430]} {app_rd_data[431]} {app_rd_data[432]} {app_rd_data[433]} {app_rd_data[434]} {app_rd_data[435]} {app_rd_data[436]} {app_rd_data[437]} {app_rd_data[438]} {app_rd_data[439]} {app_rd_data[440]} {app_rd_data[441]} {app_rd_data[442]} {app_rd_data[443]} {app_rd_data[444]} {app_rd_data[445]} {app_rd_data[446]} {app_rd_data[447]} {app_rd_data[448]} {app_rd_data[449]} {app_rd_data[450]} {app_rd_data[451]} {app_rd_data[452]} {app_rd_data[453]} {app_rd_data[454]} {app_rd_data[455]} {app_rd_data[456]} {app_rd_data[457]} {app_rd_data[458]} {app_rd_data[459]} {app_rd_data[460]} {app_rd_data[461]} {app_rd_data[462]} {app_rd_data[463]} {app_rd_data[464]} {app_rd_data[465]} {app_rd_data[466]} {app_rd_data[467]} {app_rd_data[468]} {app_rd_data[469]} {app_rd_data[470]} {app_rd_data[471]} {app_rd_data[472]} {app_rd_data[473]} {app_rd_data[474]} {app_rd_data[475]} {app_rd_data[476]} {app_rd_data[477]} {app_rd_data[478]} {app_rd_data[479]} {app_rd_data[480]} {app_rd_data[481]} {app_rd_data[482]} {app_rd_data[483]} {app_rd_data[484]} {app_rd_data[485]} {app_rd_data[486]} {app_rd_data[487]} {app_rd_data[488]} {app_rd_data[489]} {app_rd_data[490]} {app_rd_data[491]} {app_rd_data[492]} {app_rd_data[493]} {app_rd_data[494]} {app_rd_data[495]} {app_rd_data[496]} {app_rd_data[497]} {app_rd_data[498]} {app_rd_data[499]} {app_rd_data[500]} {app_rd_data[501]} {app_rd_data[502]} {app_rd_data[503]} {app_rd_data[504]} {app_rd_data[505]} {app_rd_data[506]} {app_rd_data[507]} {app_rd_data[508]} {app_rd_data[509]} {app_rd_data[510]} {app_rd_data[511]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {dram_state[0]} {dram_state[1]} {dram_state[2]} {dram_state[3]} {dram_state[4]} {dram_state[5]} {dram_state[6]} {dram_state[7]} {dram_state[8]} {dram_state[9]} {dram_state[10]} {dram_state[11]} {dram_state[12]} {dram_state[13]} {dram_state[14]} {dram_state[15]} {dram_state[16]} {dram_state[17]} {dram_state[18]} {dram_state[19]} {dram_state[20]} {dram_state[21]} {dram_state[22]} {dram_state[23]} {dram_state[24]} {dram_state[25]} {dram_state[26]} {dram_state[27]} {dram_state[28]} {dram_state[29]} {dram_state[30]} {dram_state[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 64 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {app_wdf_mask[0]} {app_wdf_mask[1]} {app_wdf_mask[2]} {app_wdf_mask[3]} {app_wdf_mask[4]} {app_wdf_mask[5]} {app_wdf_mask[6]} {app_wdf_mask[7]} {app_wdf_mask[8]} {app_wdf_mask[9]} {app_wdf_mask[10]} {app_wdf_mask[11]} {app_wdf_mask[12]} {app_wdf_mask[13]} {app_wdf_mask[14]} {app_wdf_mask[15]} {app_wdf_mask[16]} {app_wdf_mask[17]} {app_wdf_mask[18]} {app_wdf_mask[19]} {app_wdf_mask[20]} {app_wdf_mask[21]} {app_wdf_mask[22]} {app_wdf_mask[23]} {app_wdf_mask[24]} {app_wdf_mask[25]} {app_wdf_mask[26]} {app_wdf_mask[27]} {app_wdf_mask[28]} {app_wdf_mask[29]} {app_wdf_mask[30]} {app_wdf_mask[31]} {app_wdf_mask[32]} {app_wdf_mask[33]} {app_wdf_mask[34]} {app_wdf_mask[35]} {app_wdf_mask[36]} {app_wdf_mask[37]} {app_wdf_mask[38]} {app_wdf_mask[39]} {app_wdf_mask[40]} {app_wdf_mask[41]} {app_wdf_mask[42]} {app_wdf_mask[43]} {app_wdf_mask[44]} {app_wdf_mask[45]} {app_wdf_mask[46]} {app_wdf_mask[47]} {app_wdf_mask[48]} {app_wdf_mask[49]} {app_wdf_mask[50]} {app_wdf_mask[51]} {app_wdf_mask[52]} {app_wdf_mask[53]} {app_wdf_mask[54]} {app_wdf_mask[55]} {app_wdf_mask[56]} {app_wdf_mask[57]} {app_wdf_mask[58]} {app_wdf_mask[59]} {app_wdf_mask[60]} {app_wdf_mask[61]} {app_wdf_mask[62]} {app_wdf_mask[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {dram_pattern_state[0]} {dram_pattern_state[1]} {dram_pattern_state[2]} {dram_pattern_state[3]} {dram_pattern_state[4]} {dram_pattern_state[5]} {dram_pattern_state[6]} {dram_pattern_state[7]} {dram_pattern_state[8]} {dram_pattern_state[9]} {dram_pattern_state[10]} {dram_pattern_state[11]} {dram_pattern_state[12]} {dram_pattern_state[13]} {dram_pattern_state[14]} {dram_pattern_state[15]} {dram_pattern_state[16]} {dram_pattern_state[17]} {dram_pattern_state[18]} {dram_pattern_state[19]} {dram_pattern_state[20]} {dram_pattern_state[21]} {dram_pattern_state[22]} {dram_pattern_state[23]} {dram_pattern_state[24]} {dram_pattern_state[25]} {dram_pattern_state[26]} {dram_pattern_state[27]} {dram_pattern_state[28]} {dram_pattern_state[29]} {dram_pattern_state[30]} {dram_pattern_state[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list app_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list app_rd_data_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list app_rdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list app_wdf_end]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list app_wdf_rdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list app_wdf_wren]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets dram_clk]
