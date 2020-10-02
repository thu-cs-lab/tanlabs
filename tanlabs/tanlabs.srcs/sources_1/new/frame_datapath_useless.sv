`timescale 1ns / 1ps

// Example Pipeline Frame Data Path.
// It provides useless features, but lets you be familiar with tanlabs. 

module frame_datapath_useless
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
    assign in.dont_touch = 1'b0;
    assign in.dest = 0;

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

    // README: USELESS features :-)

    frame_data s1;
    wire s1_ready;
    assign in_ready = s1_ready || !in.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s1 <= 0;
        end
        else if (s1_ready)
        begin
            s1 <= in;
            if (in.valid && in.is_first && !in.drop && !in.dont_touch)
            begin
                // We only process the first beat of each frame.

                // Useless feature 1: Swap MAC addresses.
                s1.data[`MAC_DST] <= in.data[`MAC_SRC];
                s1.data[`MAC_SRC] <= in.data[`MAC_DST];
            end
        end
    end

    frame_data s2;
    wire s2_ready;
    assign s1_ready = s2_ready || !s1.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s2 <= 0;
        end
        else if (s2_ready)
        begin
            s2 <= s1;
            if (s1.valid && s1.is_first && !s1.drop && !s1.dont_touch)
            begin
                // Useless feature 2: Drop IP packets whose TTL values are odd.
                if (s1.data[`MAC_TYPE] == ETHERTYPE_IP4 && s1.data[((14 + 8) * 8)] == 1'b1)
                begin
                    s2.drop <= 1'b1;
                end
            end
        end
    end

    localparam ST_SENDRECV = 0;
    localparam ST_FOO = 1;
    localparam ST_BAR = 2;
    localparam ST_BAZ = 3;

    frame_data s3_reg, s3;
    integer s3_state;
    wire s3_ready;
    assign s2_ready = (s3_ready && s3_state == ST_SENDRECV) || !s2.valid;

    always @ (*)
    begin
        s3 = s3_reg;
        s3.valid = s3_reg.valid && s3_state == ST_SENDRECV;
    end

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s3_reg <= 0;
            s3_state <= ST_SENDRECV;
        end
        else
        begin
            // Useless feature 3: Take 3 cycles to do nothing.
            case (s3_state)
            ST_SENDRECV:
            begin
                if (s3_ready)
                begin
                    s3_reg <= s2;
                    if (s2.valid && s2.is_first && !s2.drop && !s2.dont_touch)
                    begin
                        s3_state <= ST_FOO;
                    end
                end
            end
            ST_FOO:
            begin
                s3_reg.data <= s3_reg.data ^ 1;  // Pretend to do something.
                s3_state <= ST_BAR;
            end
            ST_BAR:
            begin
                s3_reg.data <= s3_reg.data ^ 2;  // Pretend to do something.
                s3_state <= ST_BAZ;
            end
            ST_BAZ:
            begin
                s3_reg.data <= s3_reg.data ^ 3;  // Pretend to do something.
                s3_state <= ST_SENDRECV;
            end
            default:
            begin
                s3_state <= ST_SENDRECV;
            end
            endcase
        end
    end

    frame_data s4;
    wire s4_ready;
    assign s3_ready = s4_ready || !s3.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s4 <= 0;
        end
        else if (s4_ready)
        begin
            s4 <= s3;
            if (s3.valid && s3.is_first && !s3.drop && !s3.dont_touch)
            begin
                // Useless feature 4: Decrease TTL of IP packets without updating the checksums.
                if (s3.data[`MAC_TYPE] == ETHERTYPE_IP4)
                begin
                    s4.data[`IP4_TTL] <= s3.data[`IP4_TTL] - 1;
                end
            end
        end
    end

    frame_data s5;
    wire s5_ready;
    assign s4_ready = s5_ready || !s4.valid;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s5 <= 0;
        end
        else if (s5_ready)
        begin
            s5 <= s4;
            if (s4.valid && s4.is_first && !s4.drop && !s4.dont_touch)
            begin
                // Useless feature 5: Let all packets go back to their ingress interfaces.
                s5.dest <= s4.id;
            end
        end
    end

    frame_data out;
    assign out = s5;

    wire out_ready;
    assign s5_ready = out_ready || !out.valid;

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