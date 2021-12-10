`timescale 1ns / 1ps
`include "frame_datapath.vh"

module arbiter_rr_fifo
#(
    parameter DATA_WIDTH,
    parameter ID_WIDTH = 3,
    parameter [3:0] ENABLE_FIFO = 4'b1111
)
(
    input eth_clk,
    input reset,

    input frame_data in0,
    output in0_ready,
    input frame_data in1,
    output in1_ready,
    input frame_data in2,
    output in2_ready,
    input frame_data in3,
    output in3_ready,

    output frame_data out,
    input out_ready
);

    frame_data in [0:3];
    assign in[0] = in0;
    assign in[1] = in1;
    assign in[2] = in2;
    assign in[3] = in3;
    wire [3:0] in_ready;
    assign in0_ready = in_ready[0];
    assign in1_ready = in_ready[1];
    assign in2_ready = in_ready[2];
    assign in3_ready = in_ready[3];

    frame_data fifo [0:3];
    wire [3:0] fifo_ready;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1)
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

    axis_arbiter_rr axis_arbiter_rr_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid({fifo[3].valid, fifo[2].valid, fifo[1].valid, fifo[0].valid}),
        .s_axis_tready({fifo_ready[3], fifo_ready[2], fifo_ready[1], fifo_ready[0]}),
        .s_axis_tdata({fifo[3].data, fifo[2].data, fifo[1].data, fifo[0].data}),
        .s_axis_tkeep({fifo[3].keep, fifo[2].keep, fifo[1].keep, fifo[0].keep}),
        .s_axis_tlast({fifo[3].last, fifo[2].last, fifo[1].last, fifo[0].last}),
        .s_axis_tid({fifo[3].id, fifo[2].id, fifo[1].id, fifo[0].id}),
        .s_axis_tuser({fifo[3].user, fifo[2].user, fifo[1].user, fifo[0].user}),

        .m_axis_tvalid(out.valid),
        .m_axis_tready(out_ready),
        .m_axis_tdata(out.data),
        .m_axis_tkeep(out.keep),
        .m_axis_tlast(out.last),
        .m_axis_tid(out.id),
        .m_axis_tuser(out.user),

        .s_req_suppress(0),
        .s_decode_err()
    );
endmodule