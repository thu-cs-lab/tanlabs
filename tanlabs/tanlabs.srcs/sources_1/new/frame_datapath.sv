`timescale 1ns / 1ps

// Example Frame Data Path.

module frame_datapath
#(
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
    output wire [ID_WIDTH - 1:0] m_dest,
    output wire m_valid,
    input m_ready
);

    `include "frame_datapath.vh"

    frame_data in;
    wire in_ready;

    // README: Here, we use a width upsizer to change the width to 48 bytes
    // (MAC 14 + ARP 28 + round up 6) to ensure that L2 (MAC) and L3 (IPv4 or ARP) headers appear
    // in one beat (the first beat) facilitating our processing.
    // You can remove this.
    axis_dwidth_converter_up axis_dwidth_converter_up_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(s_valid),
        .s_axis_tready(s_ready),
        .s_axis_tdata(s_data),
        .s_axis_tkeep(s_keep),
        .s_axis_tlast(s_last),
        .s_axis_tid(s_id),
        .s_axis_tuser(s_user),

        .m_axis_tvalid(in.valid),
        .m_axis_tready(in_ready),
        .m_axis_tdata(in.data),
        .m_axis_tkeep(in.keep),
        .m_axis_tlast(in.last),
        .m_axis_tid(in.id),
        .m_axis_tuser(in.user)
    );

    assign in.drop = 1'b0;
    assign in.drop_next = 1'b0;

    // Track frames and figure out when it is the first beat.
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            in.is_first <= 1'b1;
        end
        else
        begin
            if (in.valid && in_ready)
            begin
                in.is_first <= in.last;
            end
        end
    end

    // README: Your code here.
    // See the guide to figure out what you need to do with frames.

    frame_data out;

    always @ (*)
    begin
        out = in;
        out.dest = in.id ^ 3'b100;  // All frames are forwarded to interface 0!
    end

    wire out_ready;
    assign in_ready = out_ready || !out.valid;

    reg out_is_first;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            out_is_first <= 1'b1;
        end
        else
        begin
            if (out.valid && out_ready)
            begin
                out_is_first <= out.last;
            end
        end
    end

    reg [ID_WIDTH - 1:0] dest;
    reg drop_by_prev;  // Dropped by the previous frame?
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            dest <= 0;
            drop_by_prev <= 1'b0;
        end
        else
        begin
            if (out_is_first && out.valid && out_ready)
            begin
                dest <= out.dest;
                drop_by_prev <= out.drop_next;
            end
        end
    end

    // Rewrite dest.
    wire [ID_WIDTH - 1:0] dest_current = out_is_first ? out.dest : dest;

    frame_data filtered;
    wire filtered_ready;

    frame_filter
    #(
        .DATA_WIDTH(DATAW_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_filter_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .s_data(out.data),
        .s_keep(out.keep),
        .s_last(out.last),
        .s_user(out.user),
        .s_id(dest_current),
        .s_valid(out.valid),
        .s_ready(out_ready),

        .drop(out.drop || drop_by_prev),

        .m_data(filtered.data),
        .m_keep(filtered.keep),
        .m_last(filtered.last),
        .m_user(filtered.user),
        .m_id(filtered.dest),
        .m_valid(filtered.valid),
        .m_ready(filtered_ready)
    );

    // README: Change the width back. You can remove this.
    axis_dwidth_converter_down axis_dwidth_converter_down_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(filtered.valid),
        .s_axis_tready(filtered_ready),
        .s_axis_tdata(filtered.data),
        .s_axis_tkeep(filtered.keep),
        .s_axis_tlast(filtered.last),
        .s_axis_tid(filtered.dest),
        .s_axis_tuser(filtered.user),

        .m_axis_tvalid(m_valid),
        .m_axis_tready(m_ready),
        .m_axis_tdata(m_data),
        .m_axis_tkeep(m_keep),
        .m_axis_tlast(m_last),
        .m_axis_tid(m_dest),
        .m_axis_tuser(m_user)
    );
endmodule