`timescale 1ns / 1ps

/* Tsinghua Advanced Networking Labs */

module tanlabs(
    input RST,

    input gtrefclk_p,
    input gtrefclk_n,

    // SFP:
    // +-+-+-+-+
    // |0|1|2|3|
    // +-+-+-+-+
    input [3:0] sfp_rx_p,
    input [3:0] sfp_rx_n,
    output wire [3:0] sfp_tx_disable,
    output wire [3:0] sfp_tx_p,
    output wire [3:0] sfp_tx_n,
    output wire [7:0] sfp_rs,
    output wire [3:0] sfp_led,

    // ETH1 RGMII
    input rgmii1_rxc,
    input rgmii1_rx_ctl,
    input [3:0] rgmii1_rxd,
    output wire rgmii1_txc,
    output wire rgmii1_tx_ctl,
    output wire [3:0] rgmii1_txd,
    output wire mdc,
    inout wire mdio,
    output wire eth_rstn
);

    assign sfp_rs = 8'hff;

    wire [4:0] debug_ingress_interconnect_ready;
    wire debug_datapath_fifo_ready;
    wire debug_egress_interconnect_ready;
    wire debug_rgmii_clk_conv_ready;

    wire reset_in = ~RST;
    wire locked;
    wire gtref_clk;  // 125MHz for the PHY/MAC IP core
    wire ref_clk;  // 200MHz for the PHY/MAC IP core
    wire core_clk;  // README: This is for CPU and other components. You can change the frequency
    // by re-customizing the following IP core.

    clk_wiz_0 clk_wiz_0_i(
        .ref_clk_out(ref_clk),
        .core_clk_out(core_clk),
        .reset(1'b0),
        .locked(locked),
        .clk_in1(gtref_clk)
    );

    wire reset_not_sync = reset_in || !locked;  // reset components

    wire mmcm_locked_out;
    wire rxuserclk_out;
    wire rxuserclk2_out;
    wire userclk_out;
    wire userclk2_out;
    wire pma_reset_out;
    wire gt0_qplloutclk_out;
    wire gt0_qplloutrefclk_out;
    wire gtref_clk_out;
    wire gtref_clk_buf_out;

    assign gtref_clk = gtref_clk_buf_out;
    wire eth_clk = userclk2_out;  // README: This is the main clock for frame processing logic,
    // 125MHz generated by the PHY/MAC IP core. 8 AXI-Streams are in this clock domain.

    wire reset_eth_not_sync = reset_in || !mmcm_locked_out;
    wire reset_eth;
    reset_sync reset_sync_reset_eth(
        .clk(eth_clk),
        .i(reset_eth_not_sync),
        .o(reset_eth)
    );

    wire [7:0] eth_tx8_data [0:4];
    wire eth_tx8_last [0:4];
    wire eth_tx8_ready [0:4];
    wire eth_tx8_user [0:4];
    wire eth_tx8_valid [0:4];

    wire [7:0] eth_rx8_data [0:4];
    wire eth_rx8_last [0:4];
    wire eth_rx8_user [0:4];
    wire eth_rx8_valid [0:4];

    // Instantiate 4 PHY/MAC IP cores.

    assign sfp_tx_disable[0] = 1'b0;
    axi_ethernet_0 axi_ethernet_0_i(
        .mac_irq(),
        .tx_mac_aclk(),
        .rx_mac_aclk(),
        .tx_reset(),
        .rx_reset(),

        .glbl_rst(reset_not_sync),

        .mmcm_locked_out(mmcm_locked_out),
        .rxuserclk_out(rxuserclk_out),
        .rxuserclk2_out(rxuserclk2_out),
        .userclk_out(userclk_out),
        .userclk2_out(userclk2_out),
        .pma_reset_out(pma_reset_out),
        .gt0_qplloutclk_out(gt0_qplloutclk_out),
        .gt0_qplloutrefclk_out(gt0_qplloutrefclk_out),
        .gtref_clk_out(gtref_clk_out),
        .gtref_clk_buf_out(gtref_clk_buf_out),

        .ref_clk(ref_clk),

        .s_axi_lite_resetn(~reset_eth),
        .s_axi_lite_clk(eth_clk),
        .s_axi_araddr(0),
        .s_axi_arready(),
        .s_axi_arvalid(0),
        .s_axi_awaddr(0),
        .s_axi_awready(),
        .s_axi_awvalid(0),
        .s_axi_bready(0),
        .s_axi_bresp(),
        .s_axi_bvalid(),
        .s_axi_rdata(),
        .s_axi_rready(0),
        .s_axi_rresp(),
        .s_axi_rvalid(),
        .s_axi_wdata(0),
        .s_axi_wready(),
        .s_axi_wvalid(0),

        .s_axis_tx_tdata(eth_tx8_data[0]),
        .s_axis_tx_tlast(eth_tx8_last[0]),
        .s_axis_tx_tready(eth_tx8_ready[0]),
        .s_axis_tx_tuser(eth_tx8_user[0]),
        .s_axis_tx_tvalid(eth_tx8_valid[0]),

        .m_axis_rx_tdata(eth_rx8_data[0]),
        .m_axis_rx_tlast(eth_rx8_last[0]),
        .m_axis_rx_tuser(eth_rx8_user[0]),
        .m_axis_rx_tvalid(eth_rx8_valid[0]),

        .s_axis_pause_tdata(0),
        .s_axis_pause_tvalid(0),

        .rx_statistics_statistics_data(),
        .rx_statistics_statistics_valid(),
        .tx_statistics_statistics_data(),
        .tx_statistics_statistics_valid(),

        .tx_ifg_delay(8'h00),
        .status_vector(),
        .signal_detect(1'b1),

        .sfp_rxn(sfp_rx_n[0]),
        .sfp_rxp(sfp_rx_p[0]),
        .sfp_txn(sfp_tx_n[0]),
        .sfp_txp(sfp_tx_p[0]),

        .mgt_clk_clk_n(gtrefclk_n),
        .mgt_clk_clk_p(gtrefclk_p)
    );

    genvar i;
    generate
        for (i = 1; i < 4; i = i + 1)
        begin
            assign sfp_tx_disable[i] = 1'b0;
            axi_ethernet_noshared axi_ethernet_noshared_i(
                .mac_irq(),
                .tx_mac_aclk(),
                .rx_mac_aclk(),
                .tx_reset(),
                .rx_reset(),

                .glbl_rst(reset_not_sync),

                .mmcm_locked(mmcm_locked_out),
                .mmcm_reset_out(),
                .rxuserclk(rxuserclk_out),
                .rxuserclk2(rxuserclk2_out),
                .userclk(userclk_out),
                .userclk2(userclk2_out),
                .pma_reset(pma_reset_out),
                .rxoutclk(),
                .txoutclk(),
                .gt0_qplloutclk_in(gt0_qplloutclk_out),
                .gt0_qplloutrefclk_in(gt0_qplloutrefclk_out),
                .gtref_clk(gtref_clk_out),
                .gtref_clk_buf(gtref_clk_buf_out),

                .ref_clk(ref_clk),

                .s_axi_lite_resetn(~reset_eth),
                .s_axi_lite_clk(eth_clk),
                .s_axi_araddr(0),
                .s_axi_arready(),
                .s_axi_arvalid(0),
                .s_axi_awaddr(0),
                .s_axi_awready(),
                .s_axi_awvalid(0),
                .s_axi_bready(0),
                .s_axi_bresp(),
                .s_axi_bvalid(),
                .s_axi_rdata(),
                .s_axi_rready(0),
                .s_axi_rresp(),
                .s_axi_rvalid(),
                .s_axi_wdata(0),
                .s_axi_wready(),
                .s_axi_wvalid(0),

                .s_axis_tx_tdata(eth_tx8_data[i]),
                .s_axis_tx_tlast(eth_tx8_last[i]),
                .s_axis_tx_tready(eth_tx8_ready[i]),
                .s_axis_tx_tuser(eth_tx8_user[i]),
                .s_axis_tx_tvalid(eth_tx8_valid[i]),

                .m_axis_rx_tdata(eth_rx8_data[i]),
                .m_axis_rx_tlast(eth_rx8_last[i]),
                .m_axis_rx_tuser(eth_rx8_user[i]),
                .m_axis_rx_tvalid(eth_rx8_valid[i]),

                .s_axis_pause_tdata(0),
                .s_axis_pause_tvalid(0),

                .rx_statistics_statistics_data(),
                .rx_statistics_statistics_valid(),
                .tx_statistics_statistics_data(),
                .tx_statistics_statistics_valid(),

                .tx_ifg_delay(8'h00),
                .status_vector(),
                .signal_detect(1'b1),

                .sfp_rxn(sfp_rx_n[i]),
                .sfp_rxp(sfp_rx_p[i]),
                .sfp_txn(sfp_tx_n[i]),
                .sfp_txp(sfp_tx_p[i])
            );
        end
    endgenerate

    wire rgmii_tx_clk;
    wire [7:0] rgmii_tx_data;
    wire rgmii_tx_last;
    wire rgmii_tx_ready;
    wire rgmii_tx_user;
    wire rgmii_tx_valid;

    wire rgmii_rx_clk;
    wire [7:0] rgmii_rx_data;
    wire rgmii_rx_last;
    wire rgmii_rx_user;
    wire rgmii_rx_valid;

    wire mdio_oe, mdi, mdo;
    assign mdi = mdio;
    assign mdio = mdio_oe ? mdo : 1'bz;

    mdio_ctrl mdio_ctrl_i(
        .clk(eth_clk),
        .reset(reset_eth),

        .mdc(mdc),
        .mdi(mdi),
        .mdo(mdo),
        .mdio_oe(mdio_oe),
        .eth_rstn(eth_rstn)
    );

    tri_mode_ethernet_mac_0 tri_mode_ethernet_mac_0_i(
        .gtx_clk(gtref_clk),                                  // input wire gtx_clk
        .gtx_clk_out(),                          // output wire gtx_clk_out
        .gtx_clk90_out(),                      // output wire gtx_clk90_out
        .glbl_rstn(~reset_not_sync),                              // input wire glbl_rstn

        .rx_axi_rstn(1'b1),                          // input wire rx_axi_rstn
        .tx_axi_rstn(1'b1),                          // input wire tx_axi_rstn
        .rx_reset(),                                // output wire rx_reset
        .tx_reset(),                                // output wire tx_reset

        .rx_statistics_vector(),        // output wire [27 : 0] rx_statistics_vector
        .rx_statistics_valid(),          // output wire rx_statistics_valid

        .rx_mac_aclk(rgmii_rx_clk),                          // output wire rx_mac_aclk
        .rx_axis_mac_tdata(rgmii_rx_data),              // output wire [7 : 0] rx_axis_mac_tdata
        .rx_axis_mac_tvalid(rgmii_rx_valid),            // output wire rx_axis_mac_tvalid
        .rx_axis_mac_tlast(rgmii_rx_last),              // output wire rx_axis_mac_tlast
        .rx_axis_mac_tuser(rgmii_rx_user),              // output wire rx_axis_mac_tuser

        .tx_mac_aclk(rgmii_tx_clk),                          // output wire tx_mac_aclk
        .tx_axis_mac_tdata(rgmii_tx_data),              // input wire [7 : 0] tx_axis_mac_tdata
        .tx_axis_mac_tvalid(rgmii_tx_valid),            // input wire tx_axis_mac_tvalid
        .tx_axis_mac_tlast(rgmii_tx_last),              // input wire tx_axis_mac_tlast
        .tx_axis_mac_tuser(rgmii_tx_user),              // input wire [0 : 0] tx_axis_mac_tuser
        .tx_axis_mac_tready(rgmii_tx_ready),            // output wire tx_axis_mac_tready

        .pause_req(1'b0),                              // input wire pause_req
        .pause_val(16'd0),                              // input wire [15 : 0] pause_val

        .refclk(ref_clk),                                    // input wire refclk

        .rgmii_txd(rgmii1_txd),                              // output wire [3 : 0] rgmii_txd
        .rgmii_tx_ctl(rgmii1_tx_ctl),                        // output wire rgmii_tx_ctl
        .rgmii_txc(rgmii1_txc),                              // output wire rgmii_txc
        .rgmii_rxd(rgmii1_rxd),                              // input wire [3 : 0] rgmii_rxd
        .rgmii_rx_ctl(rgmii1_rx_ctl),                        // input wire rgmii_rx_ctl
        .rgmii_rxc(rgmii1_rxc),                              // input wire rgmii_rxc

        .tx_ifg_delay(8'h00),                        // input wire [7 : 0] tx_ifg_delay
        .tx_statistics_vector(),        // output wire [31 : 0] tx_statistics_vector
        .tx_statistics_valid(),          // output wire tx_statistics_valid
        .speedis100(),                            // output wire speedis100
        .speedis10100(),                        // output wire speedis10100
        .inband_link_status(),            // output wire inband_link_status
        .inband_clock_speed(),            // output wire [1 : 0] inband_clock_speed
        .inband_duplex_status(),        // output wire inband_duplex_status

        // 1Gbps | Promiscuous | VLAN | Enable
        .rx_configuration_vector(80'b10100000000110),  // input wire [79 : 0] rx_configuration_vector
        // 1Gbps | VLAN | Enable
        .tx_configuration_vector(80'b10000000000110)  // input wire [79 : 0] tx_configuration_vector
    );

    axis_clock_converter_0 axis_clock_converter_rgmii_eth(
        .s_axis_aresetn(1'b1),
        .m_axis_aresetn(~reset_eth),

        .s_axis_aclk(rgmii_rx_clk),
        .s_axis_tvalid(rgmii_rx_valid),
        .s_axis_tready(debug_rgmii_clk_conv_ready),
        .s_axis_tdata(rgmii_rx_data),
        .s_axis_tlast(rgmii_rx_last),
        .s_axis_tuser(rgmii_rx_user),

        .m_axis_aclk(eth_clk),
        .m_axis_tvalid(eth_rx8_valid[4]),
        .m_axis_tready(1'b1),
        .m_axis_tdata(eth_rx8_data[4]),
        .m_axis_tlast(eth_rx8_last[4]),
        .m_axis_tuser(eth_rx8_user[4])
    );

    axis_clock_converter_0 axis_clock_converter_eth_rgmii(
        .s_axis_aresetn(~reset_eth),
        .m_axis_aresetn(1'b1),

        .s_axis_aclk(eth_clk),
        .s_axis_tvalid(eth_tx8_valid[4]),
        .s_axis_tready(eth_tx8_ready[4]),
        .s_axis_tdata(eth_tx8_data[4]),
        .s_axis_tlast(eth_tx8_last[4]),
        .s_axis_tuser(eth_tx8_user[4]),

        .m_axis_aclk(rgmii_tx_clk),
        .m_axis_tvalid(rgmii_tx_valid),
        .m_axis_tready(rgmii_tx_ready),
        .m_axis_tdata(rgmii_tx_data),
        .m_axis_tlast(rgmii_tx_last),
        .m_axis_tuser(rgmii_tx_user)
    );

    wire [7:0] out_led;
    led_delayer led_delayer_i(
        .clk(eth_clk),
        .reset(reset_eth),
        .in_led({4'b0,
                 (eth_tx8_valid[3] & eth_tx8_ready[3]) | eth_rx8_valid[3],
                 (eth_tx8_valid[2] & eth_tx8_ready[2]) | eth_rx8_valid[2],
                 (eth_tx8_valid[1] & eth_tx8_ready[1]) | eth_rx8_valid[1],
                 (eth_tx8_valid[0] & eth_tx8_ready[0]) | eth_rx8_valid[0]}),
        .out_led(out_led)
    );
    assign sfp_led = out_led[3:0];

    localparam DATA_WIDTH = 64;
    localparam ID_WIDTH = 3;

    wire [DATA_WIDTH - 1:0] eth_rx_data;
    wire [DATA_WIDTH / 8 - 1:0] eth_rx_keep;
    wire eth_rx_last;
    wire [DATA_WIDTH / 8 - 1:0] eth_rx_user;
    wire [ID_WIDTH - 1:0] eth_rx_id;
    wire eth_rx_valid;

    axis_interconnect_ingress axis_interconnect_ingress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset_eth),

        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset_eth),
        .S00_AXIS_TVALID(eth_rx8_valid[0]),
        .S00_AXIS_TREADY(debug_ingress_interconnect_ready[0]),
        .S00_AXIS_TDATA(eth_rx8_data[0]),
        .S00_AXIS_TKEEP(1'b1),
        .S00_AXIS_TLAST(eth_rx8_last[0]),
        .S00_AXIS_TID(3'd0),
        .S00_AXIS_TUSER(eth_rx8_user[0]),

        .S01_AXIS_ACLK(eth_clk),
        .S01_AXIS_ARESETN(~reset_eth),
        .S01_AXIS_TVALID(eth_rx8_valid[1]),
        .S01_AXIS_TREADY(debug_ingress_interconnect_ready[1]),
        .S01_AXIS_TDATA(eth_rx8_data[1]),
        .S01_AXIS_TKEEP(1'b1),
        .S01_AXIS_TLAST(eth_rx8_last[1]),
        .S01_AXIS_TID(3'd1),
        .S01_AXIS_TUSER(eth_rx8_user[1]),

        .S02_AXIS_ACLK(eth_clk),
        .S02_AXIS_ARESETN(~reset_eth),
        .S02_AXIS_TVALID(eth_rx8_valid[2]),
        .S02_AXIS_TREADY(debug_ingress_interconnect_ready[2]),
        .S02_AXIS_TDATA(eth_rx8_data[2]),
        .S02_AXIS_TKEEP(1'b1),
        .S02_AXIS_TLAST(eth_rx8_last[2]),
        .S02_AXIS_TID(3'd2),
        .S02_AXIS_TUSER(eth_rx8_user[2]),

        .S03_AXIS_ACLK(eth_clk),
        .S03_AXIS_ARESETN(~reset_eth),
        .S03_AXIS_TVALID(eth_rx8_valid[3]),
        .S03_AXIS_TREADY(debug_ingress_interconnect_ready[3]),
        .S03_AXIS_TDATA(eth_rx8_data[3]),
        .S03_AXIS_TKEEP(1'b1),
        .S03_AXIS_TLAST(eth_rx8_last[3]),
        .S03_AXIS_TID(3'd3),
        .S03_AXIS_TUSER(eth_rx8_user[3]),

        .S04_AXIS_ACLK(eth_clk),
        .S04_AXIS_ARESETN(~reset_eth),
        .S04_AXIS_TVALID(eth_rx8_valid[4]),
        .S04_AXIS_TREADY(debug_ingress_interconnect_ready[4]),
        .S04_AXIS_TDATA(eth_rx8_data[4]),
        .S04_AXIS_TKEEP(1'b1),
        .S04_AXIS_TLAST(eth_rx8_last[4]),
        .S04_AXIS_TID(3'd4),
        .S04_AXIS_TUSER(eth_rx8_user[4]),

        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset_eth),
        .M00_AXIS_TVALID(eth_rx_valid),
        .M00_AXIS_TREADY(1'b1),
        .M00_AXIS_TDATA(eth_rx_data),
        .M00_AXIS_TKEEP(eth_rx_keep),
        .M00_AXIS_TLAST(eth_rx_last),
        .M00_AXIS_TID(eth_rx_id),
        .M00_AXIS_TUSER(eth_rx_user),

        .S00_ARB_REQ_SUPPRESS(0),
        .S01_ARB_REQ_SUPPRESS(0),
        .S02_ARB_REQ_SUPPRESS(0),
        .S03_ARB_REQ_SUPPRESS(0),
        .S04_ARB_REQ_SUPPRESS(0),

        .S00_FIFO_DATA_COUNT(),
        .S01_FIFO_DATA_COUNT(),
        .S02_FIFO_DATA_COUNT(),
        .S03_FIFO_DATA_COUNT(),
        .S04_FIFO_DATA_COUNT()
    );

    wire [DATA_WIDTH - 1:0] dp_rx_data;
    wire [DATA_WIDTH / 8 - 1:0] dp_rx_keep;
    wire dp_rx_last;
    wire [DATA_WIDTH / 8 - 1:0] dp_rx_user;
    wire [ID_WIDTH - 1:0] dp_rx_id;
    wire dp_rx_valid;
    wire dp_rx_ready;

    frame_datapath_fifo
    #(
        .ENABLE(1),  // README: enable this if your datapath may block.
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_datapath_fifo_i(
        .eth_clk(eth_clk),
        .reset(reset_eth),

        .s_data(eth_rx_data),
        .s_keep(eth_rx_keep),
        .s_last(eth_rx_last),
        .s_user(eth_rx_user),
        .s_id(eth_rx_id),
        .s_valid(eth_rx_valid),
        .s_ready(debug_datapath_fifo_ready),

        .m_data(dp_rx_data),
        .m_keep(dp_rx_keep),
        .m_last(dp_rx_last),
        .m_user(dp_rx_user),
        .m_id(dp_rx_id),
        .m_valid(dp_rx_valid),
        .m_ready(dp_rx_ready)
    );

    wire [DATA_WIDTH - 1:0] dp_tx_data;
    wire [DATA_WIDTH / 8 - 1:0] dp_tx_keep;
    wire dp_tx_last;
    wire [DATA_WIDTH / 8 - 1:0] dp_tx_user;
    wire [ID_WIDTH - 1:0] dp_tx_dest;
    wire dp_tx_valid;

    // README: Instantiate your datapath.
    frame_datapath
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_datapath_i(
        .eth_clk(eth_clk),
        .reset(reset_eth),

        .s_data(dp_rx_data),
        .s_keep(dp_rx_keep),
        .s_last(dp_rx_last),
        .s_user(dp_rx_user),
        .s_id(dp_rx_id),
        .s_valid(dp_rx_valid),
        .s_ready(dp_rx_ready),

        .m_data(dp_tx_data),
        .m_keep(dp_tx_keep),
        .m_last(dp_tx_last),
        .m_user(dp_tx_user),
        .m_dest(dp_tx_dest),
        .m_valid(dp_tx_valid),
        .m_ready(1'b1)

        // README: You will need to add some signals for your CPU to control the datapath,
        // or access the forwarding table or the address resolution cache.
    );

    wire [DATA_WIDTH - 1:0] eth_tx_data [0:4];
    wire [DATA_WIDTH / 8 - 1:0] eth_tx_keep [0:4];
    wire eth_tx_last [0:4];
    wire eth_tx_ready [0:4];
    wire [DATA_WIDTH / 8 - 1:0] eth_tx_user [0:4];
    wire eth_tx_valid [0:4];

    axis_interconnect_egress axis_interconnect_egress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset_eth),

        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset_eth),
        .S00_AXIS_TVALID(dp_tx_valid),
        .S00_AXIS_TREADY(debug_egress_interconnect_ready),
        .S00_AXIS_TDATA(dp_tx_data),
        .S00_AXIS_TKEEP(dp_tx_keep),
        .S00_AXIS_TLAST(dp_tx_last),
        .S00_AXIS_TDEST(dp_tx_dest),
        .S00_AXIS_TUSER(dp_tx_user),

        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset_eth),
        .M00_AXIS_TVALID(eth_tx_valid[0]),
        .M00_AXIS_TREADY(eth_tx_ready[0]),
        .M00_AXIS_TDATA(eth_tx_data[0]),
        .M00_AXIS_TKEEP(eth_tx_keep[0]),
        .M00_AXIS_TLAST(eth_tx_last[0]),
        .M00_AXIS_TDEST(),
        .M00_AXIS_TUSER(eth_tx_user[0]),

        .M01_AXIS_ACLK(eth_clk),
        .M01_AXIS_ARESETN(~reset_eth),
        .M01_AXIS_TVALID(eth_tx_valid[1]),
        .M01_AXIS_TREADY(eth_tx_ready[1]),
        .M01_AXIS_TDATA(eth_tx_data[1]),
        .M01_AXIS_TKEEP(eth_tx_keep[1]),
        .M01_AXIS_TLAST(eth_tx_last[1]),
        .M01_AXIS_TDEST(),
        .M01_AXIS_TUSER(eth_tx_user[1]),

        .M02_AXIS_ACLK(eth_clk),
        .M02_AXIS_ARESETN(~reset_eth),
        .M02_AXIS_TVALID(eth_tx_valid[2]),
        .M02_AXIS_TREADY(eth_tx_ready[2]),
        .M02_AXIS_TDATA(eth_tx_data[2]),
        .M02_AXIS_TKEEP(eth_tx_keep[2]),
        .M02_AXIS_TLAST(eth_tx_last[2]),
        .M02_AXIS_TDEST(),
        .M02_AXIS_TUSER(eth_tx_user[2]),

        .M03_AXIS_ACLK(eth_clk),
        .M03_AXIS_ARESETN(~reset_eth),
        .M03_AXIS_TVALID(eth_tx_valid[3]),
        .M03_AXIS_TREADY(eth_tx_ready[3]),
        .M03_AXIS_TDATA(eth_tx_data[3]),
        .M03_AXIS_TKEEP(eth_tx_keep[3]),
        .M03_AXIS_TLAST(eth_tx_last[3]),
        .M03_AXIS_TDEST(),
        .M03_AXIS_TUSER(eth_tx_user[3]),

        .M04_AXIS_ACLK(eth_clk),
        .M04_AXIS_ARESETN(~reset_eth),
        .M04_AXIS_TVALID(eth_tx_valid[4]),
        .M04_AXIS_TREADY(eth_tx_ready[4]),
        .M04_AXIS_TDATA(eth_tx_data[4]),
        .M04_AXIS_TKEEP(eth_tx_keep[4]),
        .M04_AXIS_TLAST(eth_tx_last[4]),
        .M04_AXIS_TDEST(),
        .M04_AXIS_TUSER(eth_tx_user[4]),

        .S00_DECODE_ERR()
    );

    generate
        for (i = 0; i < 5; i = i + 1)
        begin
            egress_wrapper
            #(
                .DATA_WIDTH(DATA_WIDTH),
                .ID_WIDTH(ID_WIDTH)
            )
            egress_wrapper_i(
                .eth_clk(eth_clk),
                .reset(reset_eth),

                .s_data(eth_tx_data[i]),
                .s_keep(eth_tx_keep[i]),
                .s_last(eth_tx_last[i]),
                .s_user(eth_tx_user[i]),
                .s_valid(eth_tx_valid[i]),
                .s_ready(eth_tx_ready[i]),

                .m_data(eth_tx8_data[i]),
                .m_last(eth_tx8_last[i]),
                .m_user(eth_tx8_user[i]),
                .m_valid(eth_tx8_valid[i]),
                .m_ready(eth_tx8_ready[i])
            );
        end
    endgenerate

//    wire [7:0] debug_led;
//    led_delayer led_delayer_debug_i1(
//        .clk(eth_clk),
//        .reset(reset_eth),
//        .in_led({1'b0, ~debug_egress_interconnect_ready,
//                 ~debug_datapath_fifo_ready,
//                 ~debug_ingress_interconnect_ready}),
//        .out_led(debug_led)
//    );

    // README: You may use this to reset your CPU.
    wire reset_core;
    reset_sync reset_sync_reset_core(
        .clk(core_clk),
        .i(reset_not_sync),
        .o(reset_core)
    );

    // README: Your code here.
endmodule
