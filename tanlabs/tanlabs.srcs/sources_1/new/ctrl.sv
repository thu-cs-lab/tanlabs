`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ctrl
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3,
    parameter ID = 4
)
(
    input eth_clk,
    input reset,

    input frame_data in,
    output wire in_ready,

    output frame_data out,
    input out_ready,

    // control signals
    output config_reg_t config_reg,
    input state_reg_t state_reg
);

    frame_data filtered;
    wire filtered_ready;
    wire prog_full;

    assign in_ready = 1'b1;  // We drop frames when the FIFO is almost full, so we are always ready.

    frame_filter
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_filter_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .s_data(in.data),
        .s_keep(in.keep),
        .s_last(in.last),
        .s_user(in.user),
        .s_id(in.id),
        .s_valid(in.valid),
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

    frame_data fifo;
    wire fifo_ready;

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

        .m_axis_tvalid(fifo.valid),
        .m_axis_tready(fifo_ready),
        .m_axis_tdata(fifo.data),
        .m_axis_tkeep(fifo.keep),
        .m_axis_tlast(fifo.last),
        .m_axis_tuser(fifo.user),
        .m_axis_tid(fifo.id),

        .prog_full(prog_full)
    );

    assign fifo.dest = 0;

    typedef enum
    {
        ST_RECV
    } state_t;
    state_t state;

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            state <= ST_RECV;
        end
        else
        begin
            case (state)
            ST_RECV:
            begin
                
            end
            default:
            begin
                state <= ST_RECV;
            end
            endcase
        end
    end

    always @ (*)
    begin
        // FIXME
        out = fifo;
        out.id = ID;
    end

    assign fifo_ready = out_ready;
    assign config_reg = 0;

endmodule