`timescale 1ns / 1ps

module frame_datapath_fifo
#(
    parameter ENABLE = 0,
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input [DATA_WIDTH - 1:0] s_data,
    input [DATA_WIDTH / 8 - 1:0] s_keep,
    input s_last,
    input [DATA_WIDTH / 8 - 1:0] s_user,
    input [ID_WIDTH - 1:0] s_id,
    input s_valid,
    output wire s_ready,

    output wire [DATA_WIDTH - 1:0] m_data,
    output wire [DATA_WIDTH / 8 - 1:0] m_keep,
    output wire m_last,
    output wire [DATA_WIDTH / 8 - 1:0] m_user,
    output wire [ID_WIDTH - 1:0] m_id,
    output wire m_valid,
    input m_ready
);

    generate
        if (ENABLE)
        begin
            // We drop frames when the FIFO is almost full, so we are always ready.
            assign s_ready = 1'b1;

            wire prog_full;
            wire [DATA_WIDTH - 1:0] filtered_data;
            wire [DATA_WIDTH / 8 - 1:0] filtered_keep;
            wire filtered_last;
            wire [DATA_WIDTH / 8 - 1:0] filtered_user;
            wire [ID_WIDTH - 1:0] filtered_id;
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
                .s_id(s_id),
                .s_valid(s_valid),
                .s_ready(),

                .drop(prog_full),  // Drop this frame when the FIFO cannot hold a biggest frame.

                .m_data(filtered_data),
                .m_keep(filtered_keep),
                .m_last(filtered_last),
                .m_user(filtered_user),
                .m_id(filtered_id),
                .m_valid(filtered_valid),
                .m_ready(filtered_ready)
            );

            axis_data_fifo_datapath axis_data_fifo_datapath_i(
                .s_axis_aresetn(~reset),
                .s_axis_aclk(eth_clk),
                .s_axis_tvalid(filtered_valid),
                .s_axis_tready(filtered_ready),
                .s_axis_tdata(filtered_data),
                .s_axis_tkeep(filtered_keep),
                .s_axis_tlast(filtered_last),
                .s_axis_tid(filtered_id),
                .s_axis_tuser(filtered_user),

                .m_axis_tvalid(m_valid),
                .m_axis_tready(m_ready),
                .m_axis_tdata(m_data),
                .m_axis_tkeep(m_keep),
                .m_axis_tlast(m_last),
                .m_axis_tid(m_id),
                .m_axis_tuser(m_user),

                .prog_full(prog_full)
            );
        end
        else
        begin
            assign m_data = s_data;
            assign m_keep = s_keep;
            assign m_last = s_last;
            assign m_user = s_user;
            assign m_id = s_id;
            assign m_valid = s_valid;
            assign s_ready = m_ready;
        end
    endgenerate
endmodule