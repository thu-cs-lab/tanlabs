`timescale 1ns / 1ps
`include "frame_datapath.vh"

module frame_datapath_pop_vlan
#(
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input frame_data in,
    output wire in_ready,

    output frame_data out,
    input out_ready
);

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

    frame_data out0_reg, out0;
    reg [DATAW_WIDTH - VLAN_WIDTH - 1:0] leftover_data;
    reg [(DATAW_WIDTH - VLAN_WIDTH) / 8 - 1:0] leftover_keep, leftover_user;
    reg leftover_valid, leftover_drop;
    reg [ID_WIDTH - 1:0] leftover_dest;
    wire out0_ready;
    assign in_ready = out0_ready || !in.valid;

    vlan_tag_t in_vlan;
    assign in_vlan = in.data[96 +: VLAN_WIDTH];

    always @ (*)
    begin
        out0 = out0_reg;
    end

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            out0_reg <= 0;
            leftover_data <= 0;
            leftover_keep <= 0;
            leftover_user <= 0;
            leftover_valid <= 0;
            leftover_dest <= 0;
            leftover_drop <= 0;
        end
        else
        begin
            if (out0_ready)
            begin
                out0_reg.valid <= 1'b0;
                out0_reg.dest <= leftover_dest;
                out0_reg.drop <= leftover_drop;
                if (in.is_first)
                begin
                    // Send previous frame's leftovers.
                    out0_reg.data <= {{VLAN_WIDTH{1'b0}}, leftover_data};
                    out0_reg.keep <= {{(VLAN_WIDTH / 8){1'b0}}, leftover_keep};
                    out0_reg.user <= {{(VLAN_WIDTH / 8){1'b0}}, leftover_user};
                    out0_reg.last <= 1'b1;
                    out0_reg.valid <= leftover_valid;

                    leftover_data <= {in.data[DATAW_WIDTH - 1:128], in.data[95:0]};
                    leftover_keep <= {in.keep[DATAW_WIDTH / 8 - 1:16], in.keep[11:0]};
                    leftover_user <= {in.user[DATAW_WIDTH / 8 - 1:16], in.user[11:0]};
                    leftover_valid <= in.valid;
                    leftover_dest <= in_vlan.id[8 +: 3];
                    leftover_drop <= in_vlan.ethertype != ETHERTYPE_VLAN || |in.user[12 +: VLAN_WIDTH / 8];
                end
                else if (in.valid)
                begin
                    {leftover_data, out0_reg.data} <= {in.data, leftover_data};
                    {leftover_keep, out0_reg.keep} <= {in.keep, leftover_keep};
                    {leftover_user, out0_reg.user} <= {in.user, leftover_user};
                    out0_reg.last <= 1'b0;
                    out0_reg.valid <= 1'b1;
                end
                if (in.valid && in.last)
                begin
                    if (!in.keep[VLAN_WIDTH / 8])
                    begin
                        leftover_valid <= 1'b0;
                        out0_reg.last <= 1'b1;
                    end
                end
            end
        end
    end

    reg out0_is_first;
    reg [ID_WIDTH - 1:0] dest;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            out0_is_first <= 1'b1;
            dest <= 0;
        end
        else
        begin
            if (out0.valid && out0_ready)
            begin
                if (out0_is_first)
                begin
                    dest <= out0.dest;
                end
                out0_is_first <= out0.last;
            end
        end
    end

    wire [ID_WIDTH - 1:0] dest_current = out0_is_first ? out0.dest : dest;

    wire out0_ready_orig;
    assign out0_ready = out0_ready_orig || !out0.valid;

    frame_filter
    #(
        .DATA_WIDTH(DATAW_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_filter_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .s_data(out0.data),
        .s_keep(out0.keep),
        .s_last(out0.last),
        .s_user(out0.user),
        .s_id(dest_current),
        .s_valid(out0.valid),
        .s_ready(out0_ready_orig),

        .drop(out0.drop),

        .m_data(out.data),
        .m_keep(out.keep),
        .m_last(out.last),
        .m_user(out.user),
        .m_id(out.dest),
        .m_valid(out.valid),
        .m_ready(out_ready)
    );
endmodule