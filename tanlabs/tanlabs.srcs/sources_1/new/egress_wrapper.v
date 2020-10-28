`timescale 1ns / 1ps

module egress_wrapper
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input [DATA_WIDTH - 1:0] s_data,
    input [DATA_WIDTH / 8 - 1:0] s_keep,
    input s_last,
    input [DATA_WIDTH / 8 - 1:0] s_user,
    input s_valid,
    output wire s_ready,

    output wire [7:0] m_data,
    output wire m_last,
    output wire m_user,
    output wire m_valid,
    input m_ready
);

    assign s_ready = 1'b1;  // We drop frames when the FIFO is almost full, so we are always ready.

    wire prog_full, drop_prob;
    wire [DATA_WIDTH - 1:0] filtered_data;
    wire [DATA_WIDTH / 8 - 1:0] filtered_keep;
    wire filtered_last;
    wire [DATA_WIDTH / 8 - 1:0] filtered_user;
    wire filtered_valid;
    wire filtered_ready;

    frame_filter
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_filter_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .s_data(s_data),
        .s_keep(s_keep),
        .s_last(s_last),
        .s_user(s_user),
        .s_id(0),
        .s_valid(s_valid),
        .s_ready(),

        .drop(prog_full),  // Drop this frame when the FIFO cannot hold a biggest frame.

        .m_data(filtered_data),
        .m_keep(filtered_keep),
        .m_last(filtered_last),
        .m_user(filtered_user),
        .m_id(),
        .m_valid(filtered_valid),
        .m_ready(filtered_ready)
    );

    wire [DATA_WIDTH - 1:0] fifo_data;
    wire [DATA_WIDTH / 8 - 1:0] fifo_keep;
    wire fifo_last;
    wire [DATA_WIDTH / 8 - 1:0] fifo_user;
    wire fifo_valid;
    wire fifo_ready;

    axis_data_fifo_egress axis_data_fifo_egress_i(
        .s_axis_aresetn(~reset),
        .s_axis_aclk(eth_clk),
        .s_axis_tvalid(filtered_valid),
        .s_axis_tready(filtered_ready),
        .s_axis_tdata(filtered_data),
        .s_axis_tkeep(filtered_keep),
        .s_axis_tlast(filtered_last),
        .s_axis_tuser(filtered_user),

        .m_axis_tvalid(fifo_valid),
        .m_axis_tready(fifo_ready),
        .m_axis_tdata(fifo_data),
        .m_axis_tkeep(fifo_keep),
        .m_axis_tlast(fifo_last),
        .m_axis_tuser(fifo_user),

        .prog_full(prog_full)
    );

    axis_dwidth_converter_64_8 axis_dwidth_converter_64_8_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(fifo_valid),
        .s_axis_tready(fifo_ready),
        .s_axis_tdata(fifo_data),
        .s_axis_tkeep(fifo_keep),
        .s_axis_tlast(fifo_last),
        .s_axis_tuser(fifo_user),

        .m_axis_tvalid(m_valid),
        .m_axis_tready(m_ready),
        .m_axis_tdata(m_data),
        .m_axis_tkeep(),
        .m_axis_tlast(m_last),
        .m_axis_tuser(m_user)
    );
endmodule