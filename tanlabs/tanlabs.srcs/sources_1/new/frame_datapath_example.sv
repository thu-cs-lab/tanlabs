`timescale 1ns / 1ps

// Example Pipeline Frame Data Path.
// It provides useless features, but lets you be familiar with tanlabs. 

`include "frame_datapath.vh"

module frame_datapath_example
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input wire eth_clk,
    input wire reset,

    input wire [DATA_WIDTH - 1:0] s_data,
    input wire [DATA_WIDTH / 8 - 1:0] s_keep,
    input wire s_last,
    input wire [DATA_WIDTH / 8 - 1:0] s_user,
    input wire [ID_WIDTH - 1:0] s_id,
    input wire s_valid,
    output wire s_ready,

    output wire [DATA_WIDTH - 1:0] m_data,
    output wire [DATA_WIDTH / 8 - 1:0] m_keep,
    output wire m_last,
    output wire [DATA_WIDTH / 8 - 1:0] m_user,
    output wire [ID_WIDTH - 1:0] m_dest,
    output wire m_valid,
    input wire m_ready
);

    frame_beat in8, in;
    wire in_ready;

    always @ (*)
    begin
        in8.meta = 0;
        in8.valid = s_valid;
        in8.data = s_data;
        in8.keep = s_keep;
        in8.last = s_last;
        in8.meta.id = s_id;
        in8.user = s_user;
    end

    // Track frames and figure out when it is the first beat.
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            in8.is_first <= 1'b1;
        end
        else
        begin
            if (in8.valid && s_ready)
            begin
                in8.is_first <= in8.last;
            end
        end
    end

    // README: Here, we use a width upsizer to change the width to 56 bytes
    // (MAC 14 + IPv6 40 + round up 2) to ensure that L2 (MAC) and L3 (IPv6) headers appear
    // in one beat (the first beat) facilitating our processing.
    // You can remove this.
    frame_beat_width_converter #(DATA_WIDTH, DATAW_WIDTH) frame_beat_upsizer(
        .clk(eth_clk),
        .rst(reset),

        .in(in8),
        .in_ready(s_ready),
        .out(in),
        .out_ready(in_ready)
    );

    // README: USELESS features :-)
    // You do not have to have exactly 5 stages.

    // Meanings of "ready" signals:
    //   in_ready:   Are we ready to accept an incoming data beat?
    //   s{n}_ready: Is Stage n+1 ready to accept the data beat from Stage n, or,
    //               is the data beat from Stage n a bubble (valid == 1'b0) so that
    //               Stage n+1 can pretend to be ready and consume this bubble?
    //   out_ready:  Is our downstream ready to accept a data beat from us?

    frame_beat s1;
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
            // We can proceed only when the next stage is ready to accept the data beat from this
            // stage (s1_ready == 1'b1) so that the buffer (s1) is free to store a new data beat
            // from the previous stage.
            // Otherwise (s1_ready == 1'b0), we must keep the buffer unchanged and wait for the
            // next stage, or the current beat will be lost.

            s1 <= in;
            if (`should_handle(in))
            begin
                // We only process the beat that (should_handle)
                //   1) is valid, otherwise its data is **garbage**;
                //   2) is the first beat of a frame, since only the first beat contains needed
                //      headers;
                //   3) is not dropped by previous stages;
                //   4) is not marked as "do not touch" by previous stages.

                // Useless feature 1: Swap MAC addresses.
                s1.data.dst <= in.data.src;
                s1.data.src <= in.data.dst;
            end
        end
    end

    frame_beat s2;
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
            if (`should_handle(s1))
            begin
                // Useless feature 2: Drop IPv6 packets whose hop limit values are odd.
                if (s1.data.ethertype == ETHERTYPE_IP6 && s1.data.ip6.hop_limit[0] == 1'b1)
                begin
                    s2.meta.drop <= 1'b1;
                end
            end
        end
    end

    typedef enum
    {
        ST_SEND_RECV,
        ST_FOO,
        ST_BAR,
        ST_BAZ
    } s3_state_t;

    frame_beat s3_reg, s3;
    s3_state_t s3_state;
    wire s3_ready;
    assign s2_ready = (s3_ready && s3_state == ST_SEND_RECV) || !s2.valid;

    always @ (*)
    begin
        s3 = s3_reg;
        s3.valid = s3_reg.valid && s3_state == ST_SEND_RECV;
    end

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            s3_reg <= 0;
            s3_state <= ST_SEND_RECV;
        end
        else
        begin
            // Useless feature 3: Take 3 cycles to do nothing.
            case (s3_state)
            ST_SEND_RECV:
            begin
                if (s3_ready)
                begin
                    s3_reg <= s2;
                    if (`should_handle(s2))
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
                s3_state <= ST_SEND_RECV;
            end
            default:
            begin
                s3_state <= ST_SEND_RECV;
            end
            endcase
        end
    end

    frame_beat s4;
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
            if (`should_handle(s3))
            begin
                // Useless feature 4: Decrease hop limit of IPv6 packets.
                if (s3.data.ethertype == ETHERTYPE_IP6)
                begin
                    s4.data.ip6.hop_limit <= s3.data.ip6.hop_limit - 1;
                end
            end
        end
    end

    frame_beat s5;
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
            if (`should_handle(s4))
            begin
                // Useless feature 5: Let all packets go back to their ingress interfaces.
                s5.meta.dest <= s4.meta.id;
            end
        end
    end

    frame_beat out;
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
                dest <= out.meta.dest;
                drop_by_prev <= out.meta.drop_next;
            end
        end
    end

    // Rewrite dest.
    wire [ID_WIDTH - 1:0] dest_current = out_is_first ? out.meta.dest : dest;

    frame_beat filtered;
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

        .drop(out.meta.drop || drop_by_prev),

        .m_data(filtered.data),
        .m_keep(filtered.keep),
        .m_last(filtered.last),
        .m_user(filtered.user),
        .m_id(filtered.meta.dest),
        .m_valid(filtered.valid),
        .m_ready(filtered_ready)
    );

    // README: Change the width back. You can remove this.
    frame_beat out8;
    frame_beat_width_converter #(DATAW_WIDTH, DATA_WIDTH) frame_beat_downsizer(
        .clk(eth_clk),
        .rst(reset),

        .in(filtered),
        .in_ready(filtered_ready),
        .out(out8),
        .out_ready(m_ready)
    );

    assign m_valid = out8.valid;
    assign m_data = out8.data;
    assign m_keep = out8.keep;
    assign m_last = out8.last;
    assign m_dest = out8.meta.dest;
    assign m_user = out8.user;
endmodule
