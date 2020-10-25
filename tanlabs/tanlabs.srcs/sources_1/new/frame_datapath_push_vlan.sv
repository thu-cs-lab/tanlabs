`timescale 1ns / 1ps

module frame_datapath_push_vlan
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

    typedef enum
    {
        ST_SEND_RECV,
        ST_SEND_LAST
    } out_state_t;

    frame_data out_reg, out;
    out_state_t out_state;
    reg [VLAN_WIDTH - 1:0] leftover_data;
    reg [VLAN_WIDTH / 8 - 1:0] leftover_keep, leftover_user;
    wire out_ready;
    assign in_ready = (out_ready && out_state == ST_SEND_RECV) || !in.valid;

    vlan_tag_t in_vlan;
    assign in_vlan.ethertype = ETHERTYPE_VLAN;
    assign in_vlan.id = {4'h0, 1'b0, in.id, 8'h01};

    always @ (*)
    begin
        out = out_reg;
        out.drop = 1'b0;
        out.drop_next = 1'b0;
        out.dest = 4;
    end

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            out_reg <= 0;
            out_state <= ST_SEND_RECV;
            leftover_data <= 0;
            leftover_keep <= 0;
            leftover_user <= 0;
        end
        else
        begin
            case (out_state)
            ST_SEND_RECV:
            begin
                if (out_ready)
                begin
                    out_reg.valid <= 1'b0;
                    if (in.valid)
                    begin
                        out_reg.valid <= 1'b1;
                        if (in.is_first)
                        begin
                            {leftover_data, out_reg.data} <= {in.data[DATAW_WIDTH - 1:96], in_vlan, in.data[95:0]};
                            {leftover_keep, out_reg.keep} <= {in.keep[DATAW_WIDTH / 8 - 1:12], {(VLAN_WIDTH / 8){1'b1}}, in.keep[11:0]};
                            {leftover_user, out_reg.user} <= {in.user[DATAW_WIDTH / 8 - 1:12], {(VLAN_WIDTH / 8){1'b0}}, in.user[11:0]};
                        end
                        else
                        begin
                            {leftover_data, out_reg.data} <= {in.data, leftover_data};
                            {leftover_keep, out_reg.keep} <= {in.keep, leftover_keep};
                            {leftover_user, out_reg.user} <= {in.user, leftover_user};
                        end
                        out_reg.last <= in.last;
                        if (in.last)
                        begin
                            if (in.keep[(DATAW_WIDTH - VLAN_WIDTH) / 8])
                            begin
                                out_state <= ST_SEND_LAST;
                                out_reg.last <= 1'b0;
                            end
                        end
                    end
                end
            end
            ST_SEND_LAST:
            begin
                if (out_ready)
                begin
                    out_reg.data <= {{(DATAW_WIDTH - VLAN_WIDTH){1'b0}}, leftover_data};
                    out_reg.keep <= {{((DATAW_WIDTH - VLAN_WIDTH) / 8){1'b0}}, leftover_keep};
                    out_reg.user <= {{((DATAW_WIDTH - VLAN_WIDTH) / 8){1'b0}}, leftover_user};
                    out_reg.last <= 1'b1;
                    out_state <= ST_SEND_RECV;
                end
            end
            default:
            begin
                out_state <= ST_SEND_RECV;
            end
            endcase
        end
    end

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

    wire out_ready_orig;
    assign out_ready = out_ready_orig || !out.valid;

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
        .s_ready(out_ready_orig),

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