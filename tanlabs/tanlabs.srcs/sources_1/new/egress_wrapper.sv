`timescale 1ns / 1ps
`include "frame_datapath.vh"

module egress_wrapper
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3,
    parameter [1:0] ENABLE_FIFO = 2'b11,
    parameter ENABLE_VLAN_TAGGER = 0
)
(
    input eth_clk,
    input reset,

    input frame_data in0,
    output wire in0_ready,
    input frame_data in1,
    output wire in1_ready,

    output wire [7:0] m_data,
    output wire m_last,
    output wire m_user,
    output wire m_valid,
    input m_ready
);

    frame_data in [0:1];
    assign in[0] = in0;
    assign in[1] = in1;
    wire [1:0] in_ready;
    assign in0_ready = in_ready[0];
    assign in1_ready = in_ready[1];

    frame_data fifo [0:1];
    wire [1:0] fifo_ready;

    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1)
        begin
            if (ENABLE_FIFO[i])
            begin
                frame_data filtered;
                wire filtered_ready;
                wire prog_full;

                assign in_ready[i] = 1'b1;  // We drop frames when the FIFO is almost full, so we are always ready.

                frame_filter
                #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ID_WIDTH(ID_WIDTH)
                )
                frame_filter_i(
                    .eth_clk(eth_clk),
                    .reset(reset),

                    .s_data(in[i].data),
                    .s_keep(in[i].keep),
                    .s_last(in[i].last),
                    .s_user(in[i].user),
                    .s_id(in[i].id),
                    .s_valid(in[i].valid),
                    .s_ready(),

                    .drop(prog_full),  // Drop this frame when the FIFO cannot hold a biggest frame.

                    .m_data(filtered.data),
                    .m_keep(filtered.keep),
                    .m_last(filtered.last),
                    .m_user(filtered.user),
                    .m_id(filtered.id),
                    .m_valid(filtered.valid),
                    .m_ready(filtered_ready)
                );

                axis_data_fifo_egress axis_data_fifo_egress_i(
                    .s_axis_aresetn(~reset),
                    .s_axis_aclk(eth_clk),
                    .s_axis_tvalid(filtered.valid),
                    .s_axis_tready(filtered_ready),
                    .s_axis_tdata(filtered.data),
                    .s_axis_tkeep(filtered.keep),
                    .s_axis_tlast(filtered.last),
                    .s_axis_tuser(filtered.user),
                    .s_axis_tid(filtered.id),

                    .m_axis_tvalid(fifo[i].valid),
                    .m_axis_tready(fifo_ready[i]),
                    .m_axis_tdata(fifo[i].data),
                    .m_axis_tkeep(fifo[i].keep),
                    .m_axis_tlast(fifo[i].last),
                    .m_axis_tuser(fifo[i].user),
                    .m_axis_tid(fifo[i].id),

                    .prog_full(prog_full)
                );
            end
            else
            begin
                assign fifo[i] = in[i];
                assign in_ready[i] = fifo_ready[i];
            end
        end
    endgenerate

    frame_data mixed;
    wire mixed_ready;

    axis_arbiter_egress axis_arbiter_egress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset),
        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset),
        .S01_AXIS_ACLK(eth_clk),
        .S01_AXIS_ARESETN(~reset),
        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset),

        .S00_AXIS_TVALID(fifo[0].valid),
        .S00_AXIS_TREADY(fifo_ready[0]),
        .S00_AXIS_TDATA(fifo[0].data),
        .S00_AXIS_TKEEP(fifo[0].keep),
        .S00_AXIS_TLAST(fifo[0].last),
        .S00_AXIS_TID(fifo[0].id),
        .S00_AXIS_TUSER(fifo[0].user),

        .S01_AXIS_TVALID(fifo[1].valid),
        .S01_AXIS_TREADY(fifo_ready[1]),
        .S01_AXIS_TDATA(fifo[1].data),
        .S01_AXIS_TKEEP(fifo[1].keep),
        .S01_AXIS_TLAST(fifo[1].last),
        .S01_AXIS_TID(fifo[1].id),
        .S01_AXIS_TUSER(fifo[1].user),

        .M00_AXIS_TVALID(mixed.valid),
        .M00_AXIS_TREADY(mixed_ready),
        .M00_AXIS_TDATA(mixed.data),
        .M00_AXIS_TKEEP(mixed.keep),
        .M00_AXIS_TLAST(mixed.last),
        .M00_AXIS_TID(mixed.id),
        .M00_AXIS_TUSER(mixed.user),

        .S00_ARB_REQ_SUPPRESS(1'b0),
        .S01_ARB_REQ_SUPPRESS(1'b0)
    );

    frame_data vlan;
    wire vlan_ready;

    generate
        if (ENABLE_VLAN_TAGGER)
        begin
            frame_datapath_push_vlan
            #(
                .ID_WIDTH(ID_WIDTH)
            )
            frame_datapath_push_vlan_i(
                .eth_clk(eth_clk),
                .reset(reset),

                .in(mixed),
                .in_ready(mixed_ready),

                .out(vlan),
                .out_ready(vlan_ready)
            );
        end
        else
        begin
            assign vlan = mixed;
            assign mixed_ready = vlan_ready;
        end
    endgenerate

    axis_dwidth_converter_egress axis_dwidth_converter_egress_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(vlan.valid),
        .s_axis_tready(vlan_ready),
        .s_axis_tdata(vlan.data),
        .s_axis_tkeep(vlan.keep),
        .s_axis_tlast(vlan.last),
        .s_axis_tuser(vlan.user),

        .m_axis_tvalid(m_valid),
        .m_axis_tready(m_ready),
        .m_axis_tdata(m_data),
        .m_axis_tkeep(),
        .m_axis_tlast(m_last),
        .m_axis_tuser(m_user)
    );
endmodule