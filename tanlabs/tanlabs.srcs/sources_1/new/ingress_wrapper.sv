`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ingress_wrapper
#(
    parameter DATA_WIDTH,
    parameter ID_WIDTH = 3,
    parameter ID = 0
)
(
    input eth_clk,
    input reset,

    input [7:0] s_data,
    input s_last,
    input s_user,
    input s_valid,

    // output to control plane
    output frame_data out,
    input out_ready,

    // control signals
    input interface_config_t interface_config,
    output interface_recv_state_t interface_state,

    input wire [63:0] ticks
);

    frame_data in;
    wire in_ready;

    axis_dwidth_converter_ingress axis_dwidth_converter_ingress_i(
        .aclk(eth_clk),
        .aresetn(~reset),

        .s_axis_tvalid(s_valid),
        .s_axis_tready(),
        .s_axis_tdata(s_data),
        .s_axis_tkeep(1'b1),
        .s_axis_tlast(s_last),
        .s_axis_tuser(s_user),

        .m_axis_tvalid(in.valid),
        .m_axis_tready(in_ready),
        .m_axis_tdata(in.data),
        .m_axis_tkeep(in.keep),
        .m_axis_tlast(in.last),
        .m_axis_tuser(in.user)
    );

    // Check dst MAC and dst IP.
    wire to_data_plane =
        in.data.dst == interface_config.mac
        && in.data.ethertype == ETHERTYPE_IP6
        && in.data.payload.ip6.next_hdr == PROTO_TEST;

    wire new_dest = to_data_plane;
    reg saved_dest;

    reg is_first;  // If previous is the last one, this is the first one.
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            is_first <= 1'b1;
            saved_dest <= 1'b0;
        end
        else
        begin
            if (in.valid && in_ready)
            begin
                if (is_first)
                begin
                    saved_dest <= new_dest;
                end
                is_first <= in.last;
            end
        end
    end

    wire current_dest = is_first ? new_dest : saved_dest;

    // data plane
    frame_data dp;
    wire dp_ready;

    axis_dispatcher_ingress axis_dispatcher_ingress_i(
        .ACLK(eth_clk),
        .ARESETN(~reset),
        .S00_AXIS_ACLK(eth_clk),
        .S00_AXIS_ARESETN(~reset),
        .M00_AXIS_ACLK(eth_clk),
        .M00_AXIS_ARESETN(~reset),
        .M01_AXIS_ACLK(eth_clk),
        .M01_AXIS_ARESETN(~reset),

        .S00_AXIS_TVALID(in.valid),
        .S00_AXIS_TREADY(in_ready),
        .S00_AXIS_TDATA(in.data),
        .S00_AXIS_TKEEP(in.keep),
        .S00_AXIS_TLAST(in.last),
        .S00_AXIS_TDEST(current_dest),
        .S00_AXIS_TUSER(in.user),

        .M00_AXIS_TVALID(out.valid),
        .M00_AXIS_TREADY(out_ready),
        .M00_AXIS_TDATA(out.data),
        .M00_AXIS_TKEEP(out.keep),
        .M00_AXIS_TLAST(out.last),
        .M00_AXIS_TDEST(),
        .M00_AXIS_TUSER(out.user),

        .M01_AXIS_TVALID(dp.valid),
        .M01_AXIS_TREADY(dp_ready),
        .M01_AXIS_TDATA(dp.data),
        .M01_AXIS_TKEEP(dp.keep),
        .M01_AXIS_TLAST(dp.last),
        .M01_AXIS_TDEST(),
        .M01_AXIS_TUSER(dp.user),

        .S00_DECODE_ERR()
    );

    assign out.id = ID;

    assign dp_ready = 1'b1;

    function [DATA_WIDTH / 8 - 1:0] len2keep;
        input [15:0] len;
        reg [15:0] i;
    begin
        len2keep = 0;
        for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
        begin
            len2keep[i] = i < len;
        end
    end
    endfunction

    function [15:0] keep2len;
        input [DATA_WIDTH / 8 - 1:0] keep;
        reg [15:0] i; 
    begin
        keep2len = 0;
        for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
        begin
            if (keep[i])
            begin
                keep2len = i + 1;
            end
        end
    end
    endfunction

    wire [63:0] pattern;
    wire [63:0] set_pattern;
    wire set_lfsr;
    wire lfsr_ce;
    lfsr lfsr_i(
        .clk(eth_clk),
        .reset(reset),

        .ce(lfsr_ce),

        .set(set_lfsr),
        .i(set_pattern),

        .o(pattern)
    );

    typedef enum
    {
        ST_RECV_HEADER,
        ST_RECV_FIRST_PAYLOAD,
        ST_RECV_PAYLOAD
    } state_t;

    state_t state;

    reg [63:0] nbytes, nbytes_l3;
    wire [63:0] current_nbytes = nbytes + keep2len(dp.keep);
    reg error;
    reg current_error;
    reg [63:0] latency;
    reg [15:0] remaining_bytes;
    wire [15:0] payload_len = {<<8{dp.data.payload.ip6.payload_len}};
    wire [15:0] remaining_bytes_mux = state == ST_RECV_HEADER ?
        payload_len + 54
        : remaining_bytes;
    reg expected_last;
    reg [DATA_WIDTH / 8 - 1:0] expected_keep;

    integer i;
    reg [DATA_WIDTH - 1:0] expected_keep_bit;
    always @ (*)
    begin
        for (i = 0; i < DATA_WIDTH; i = i + 1)
        begin
            expected_keep_bit[i] = expected_keep[i / 8];
        end
    end

    wire [63:0] expected_pattern64 = state == ST_RECV_FIRST_PAYLOAD ? dp.data[63:0] : pattern;
    wire [DATA_WIDTH - 1:0] expected_pattern = expand_pattern(expected_pattern64);
    wire pattern_mismatch = |((dp.data ^ expected_pattern) & expected_keep_bit);

    assign set_pattern = dp.data[63:0];
    assign set_lfsr = dp.valid && state == ST_RECV_FIRST_PAYLOAD;
    assign lfsr_ce = dp.valid;

    always @ (*)
    begin
        current_error = error | |dp.user;

        if (state == ST_RECV_HEADER)
        begin
            if (dp.data.payload.ip6.version != 4'd6
                || dp.data.payload.ip6.flow_hi != 4'd0)
            begin
                current_error = 1'b1;
            end

            // Report an error when the frame is shorter than expected.
            if (remaining_bytes_mux <= DATA_WIDTH / 8)
            begin
                current_error |= !dp.keep[remaining_bytes_mux - 1];
            end
            else
            begin
                current_error |= dp.last;
            end
        end
        else
        begin
            current_error |= pattern_mismatch;

            // Report an error when the frame is shorter than expected.
            if (!expected_last && dp.last)
            begin
                current_error = 1'b1;
            end
            if ((expected_keep & dp.keep) != expected_keep)
            begin
                current_error = 1'b1;
            end
        end
    end

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            state <= ST_RECV_HEADER;
            interface_state <= 0;
            nbytes <= 0;
            error <= 1'b0;
            latency <= 0;
            remaining_bytes <= 0;
            expected_last <= 1'b0;
            expected_keep <= 0;
        end
        else
        begin
            if (dp.valid)
            begin
                case (state)
                ST_RECV_HEADER:
                begin
                    latency <= ticks[31:0] - {dp.data.payload.ip6.flow_lo[15:8],
                                              dp.data.payload.ip6.flow_lo[23:16],
                                              dp.data.payload.ip6.payload[7:0],
                                              dp.data.payload.ip6.flow_lo[7:0]};
                    nbytes_l3 <= remaining_bytes_mux;
                    state <= ST_RECV_FIRST_PAYLOAD;
                end
                ST_RECV_FIRST_PAYLOAD:
                begin
                    state <= ST_RECV_PAYLOAD;
                end
                ST_RECV_PAYLOAD:
                begin
                end
                default:
                begin
                    state <= ST_RECV_HEADER;
                end
                endcase

                if (remaining_bytes_mux <= DATA_WIDTH / 8)
                begin
                    remaining_bytes <= 0;
                    expected_last <= 1'b1;
                    expected_keep <= 0;
                end
                else if (remaining_bytes_mux <= DATA_WIDTH / 8 * 2)
                begin
                    remaining_bytes <= remaining_bytes_mux - DATA_WIDTH / 8;
                    expected_last <= 1'b1;
                    expected_keep <= len2keep(remaining_bytes_mux - DATA_WIDTH / 8);
                end
                else
                begin
                    remaining_bytes <= remaining_bytes_mux - DATA_WIDTH / 8;
                    expected_last <= 1'b0;
                    expected_keep <= {(DATA_WIDTH / 8){1'b1}};
                end

                if (dp.last)
                begin
                    if (current_error)
                    begin
                        interface_state.nerror <= interface_state.nerror + 1;
                    end
                    else
                    begin
                        interface_state.nbytes <= interface_state.nbytes + current_nbytes;
                        interface_state.nbytes_l3 <= interface_state.nbytes_l3 + nbytes_l3;
                        interface_state.npackets <= interface_state.npackets + 1;
                        interface_state.latency <= latency;
                    end

                    nbytes <= 0;
                    error <= 1'b0;

                    state <= ST_RECV_HEADER;
                end
                else
                begin
                    nbytes <= current_nbytes;
                    error <= current_error;
                end
            end

            if (interface_config.reset_counters)
            begin
                interface_state <= 0;
            end
        end
    end
endmodule