`timescale 1ns / 1ps
`include "frame_datapath.vh"

module frame_gen
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    output frame_data out,
    input out_ready,

    // control signals
    input interface_config_t interface_config,
    output interface_send_state_t interface_state
);

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

    typedef enum
    {
        ST_SEND_HEADER,
        ST_SEND_PAYLOAD,
        ST_GAP
    } state_t;

    state_t state;

    reg [15:0] packet_len;
    reg [15:0] remaining_bytes;
    reg [63:0] gap_counter;

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            interface_state <= 0;
            out <= 0;
            packet_len <= 0;
            remaining_bytes <= 0;
            gap_counter <= 0;
        end
        else
        begin
            case (state)
            ST_SEND_HEADER:
            begin
                if (out_ready || !out.valid)
                begin
                    // TODO: gap counter
                    if (out.valid)
                    begin
                        out.valid <= 1'b0;
                        // count previous packet.
                        interface_state.nbytes <= interface_state.nbytes + packet_len;
                        interface_state.npackets <= interface_state.npackets + 1;
                    end
                    if (interface_config.enable)
                    begin
                        out.valid <= 1'b1;
                        out.data.dst <= interface_config.mac_dst;
                        out.data.src <= interface_config.mac;
                        out.data.ethertype <= ETHERTYPE_IP4;
                        out.data.payload.ip4.version <= 4'd4;
                        out.data.payload.ip4.ihl <= 4'd5;
                        out.data.payload.ip4.total_len <= interface_config.packet_len - 14;
                        out.data.payload.ip4.ttl <= 8'd64;
                        out.data.payload.ip4.id <= 16'h55aa;  // TODO!
                        out.data.payload.ip4.proto <= PROTO_TEST;
                        out.data.payload.ip4.checksum <= 0;  // TODO!
                        out.data.payload.ip4.src <= interface_config.ip_src;
                        out.data.payload.ip4.dst <= interface_config.ip_dst;
                        out.data.payload.ip4.payload = 1;  // TODO!
                        out.keep <= len2keep(interface_config.packet_len);
                        packet_len <= interface_config.packet_len;
                        remaining_bytes <= interface_config.packet_len - DATA_WIDTH / 8;
                        if (interface_config.packet_len > DATA_WIDTH / 8)
                        begin
                            out.last <= 1'b0;
                            state <= ST_SEND_PAYLOAD;
                        end
                        else
                        begin
                            out.last <= 1'b1;
                            if (interface_config.gap_len != 0)
                            begin
                                gap_counter <= interface_config.gap_len;
                                state <= ST_GAP;
                            end
                            else
                            begin
                                state <= ST_SEND_HEADER;
                            end
                        end
                    end
                end
            end
            ST_SEND_PAYLOAD:
            begin
                if (out_ready)
                begin
                    out.valid <= 1'b1;
                    out.data.payload <= 2;
                    out.keep <= len2keep(remaining_bytes);
                    remaining_bytes <= remaining_bytes - DATA_WIDTH / 8;
                    if (remaining_bytes > DATA_WIDTH / 8)
                    begin
                        out.last <= 1'b0;
                        state <= ST_SEND_PAYLOAD;
                    end
                    else
                    begin
                        out.last <= 1'b1;
                        if (interface_config.gap_len != 0)
                        begin
                            gap_counter <= interface_config.gap_len;
                            state <= ST_GAP;
                        end
                        else
                        begin
                            state <= ST_SEND_HEADER;
                        end
                    end
                end
            end
            ST_GAP:
            begin
                if (out_ready)
                begin
                    out.valid <= 1'b0;
                end
                if (gap_counter - 1 == 0)
                begin
                    state <= ST_SEND_HEADER;
                end
                gap_counter <= gap_counter - 1;
            end
            default:
            begin
                state <= ST_SEND_HEADER;
            end
            endcase
        end
    end
endmodule