`timescale 1ns / 1ps
`include "frame_datapath.vh"

module egress_wrapper
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter [1:0] ENABLE_FIFO = 2'b11
)
(
    input eth_clk,
    input reset,

    input frame_data s0,
    output wire s0_ready,
    input frame_data s1,
    output wire s1_ready,

    output wire [7:0] m_data,
    output wire m_last,
    output wire m_user,
    output wire m_valid,
    input m_ready
);

    frame_data in [0:1];
    assign in[0] = s0;
    assign in[1] = s1;
    wire [1:0] in_ready;
    assign s0_ready = in_ready[0];
    assign s1_ready = in_ready[1];

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
                    .ID_WIDTH(1)
                )
                frame_filter_i(
                    .eth_clk(eth_clk),
                    .reset(reset),
            
                    .s_data(in[i].data),
                    .s_keep(in[i].keep),
                    .s_last(in[i].last),
                    .s_user(in[i].user),
                    .s_id(0),
                    .s_valid(in[i].valid),
                    .s_ready(),

                    .drop(prog_full),  // Drop this frame when the FIFO cannot hold a biggest frame.

                    .m_data(filtered.data),
                    .m_keep(filtered.keep),
                    .m_last(filtered.last),
                    .m_user(filtered.user),
                    .m_id(),
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

                    .m_axis_tvalid(fifo[i].valid),
                    .m_axis_tready(fifo_ready[i]),
                    .m_axis_tdata(fifo[i].data),
                    .m_axis_tkeep(fifo[i].keep),
                    .m_axis_tlast(fifo[i].last),
                    .m_axis_tuser(fifo[i].user),

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

    // TODO
endmodule