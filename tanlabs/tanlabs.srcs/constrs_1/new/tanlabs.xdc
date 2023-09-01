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
