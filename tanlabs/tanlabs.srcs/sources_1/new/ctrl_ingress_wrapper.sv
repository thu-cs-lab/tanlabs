`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ctrl_ingress_wrapper
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input [7:0] s_data,
    input s_last,
    input s_user,
    input s_valid,

    output frame_data out0,
    input out0_ready,
    output frame_data out1,
    input out1_ready,
    output frame_data out2,
    input out2_ready,
    output frame_data out3,
    input out3_ready,

    output frame_data out_ctrl,
    input out_ctrl_ready
);

    frame_data vlan;
    wire vlan_ready;

    axis_dwidth_converter_ingress axis_dwidth_converter_ingress_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(s_valid),
        .s_axis_tready(),
        .s_axis_tdata(s_data),
        .s_axis_tkeep(1'b1),
        .s_axis_tlast(s_last),
        .s_axis_tuser(s_user),

        .m_axis_tvalid(vlan.valid),
        .m_axis_tready(vlan_ready),
        .m_axis_tdata(vlan.data),
        .m_axis_tkeep(vlan.keep),
        .m_axis_tlast(vlan.last),
        .m_axis_tuser(vlan.user)
    );

    frame_data in;
    wire in_ready;

    frame_datapath_pop_vlan
    #(
        .ID_WIDTH(ID_WIDTH)
    )
    frame_datapath_pop_vlan_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .in(vlan),
        .in_ready(vlan_ready),

        .out(in),
        .out_ready(in_ready)
    );

    axis_dispatcher_ctrl_ingress axis_dispatcher_ctrl_ingress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset),
        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset),
        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset),
        .M01_AXIS_ACLK(eth_clk),
        .M01_AXIS_ARESETN(~reset),
        .M02_AXIS_ACLK(eth_clk),
        .M02_AXIS_ARESETN(~reset),
        .M03_AXIS_ACLK(eth_clk),
        .M03_AXIS_ARESETN(~reset),
        .M04_AXIS_ACLK(eth_clk),
        .M04_AXIS_ARESETN(~reset),

        .S00_AXIS_TVALID(in.valid),
        .S00_AXIS_TREADY(in_ready),
        .S00_AXIS_TDATA(in.data),
        .S00_AXIS_TKEEP(in.keep),
        .S00_AXIS_TLAST(in.last),
        .S00_AXIS_TDEST(in.dest),
        .S00_AXIS_TUSER(in.user),

        .M00_AXIS_TVALID(out0.valid),
        .M00_AXIS_TREADY(out0_ready),
        .M00_AXIS_TDATA(out0.data),
        .M00_AXIS_TKEEP(out0.keep),
        .M00_AXIS_TLAST(out0.last),
        .M00_AXIS_TDEST(),
        .M00_AXIS_TUSER(out0.user),

        .M01_AXIS_TVALID(out1.valid),
        .M01_AXIS_TREADY(out1_ready),
        .M01_AXIS_TDATA(out1.data),
        .M01_AXIS_TKEEP(out1.keep),
        .M01_AXIS_TLAST(out1.last),
        .M01_AXIS_TDEST(),
        .M01_AXIS_TUSER(out1.user),

        .M02_AXIS_TVALID(out2.valid),
        .M02_AXIS_TREADY(out2_ready),
        .M02_AXIS_TDATA(out2.data),
        .M02_AXIS_TKEEP(out2.keep),
        .M02_AXIS_TLAST(out2.last),
        .M02_AXIS_TDEST(),
        .M02_AXIS_TUSER(out2.user),

        .M03_AXIS_TVALID(out3.valid),
        .M03_AXIS_TREADY(out3_ready),
        .M03_AXIS_TDATA(out3.data),
        .M03_AXIS_TKEEP(out3.keep),
        .M03_AXIS_TLAST(out3.last),
        .M03_AXIS_TDEST(),
        .M03_AXIS_TUSER(out3.user),

        .M04_AXIS_TVALID(out_ctrl.valid),
        .M04_AXIS_TREADY(out_ctrl_ready),
        .M04_AXIS_TDATA(out_ctrl.data),
        .M04_AXIS_TKEEP(out_ctrl.keep),
        .M04_AXIS_TLAST(out_ctrl.last),
        .M04_AXIS_TDEST(),
        .M04_AXIS_TUSER(out_ctrl.user),

        .S00_DECODE_ERR()
    );
endmodule