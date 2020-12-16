`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ingress_wrapper
#(
    parameter DATA_WIDTH = 8 * 48,
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

    // TODO: control signals
    input interface_config_t interface_config,
    output interface_recv_state_t interface_state
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

    // TODO: check dst MAC and dst IP.
    wire to_data_plane =
        in.data.dst == interface_config.mac
        && in.data.ethertype == ETHERTYPE_IP4
        && in.data.payload.ip4.proto == PROTO_TEST
        && in.data.payload.ip4.payload.udp.payload == UDP_PAYLOAD_MAGIC; 

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

//    typedef enum
//    {
//        ST_
//    } state_t;

//    state_t state;
    assign dp_ready = 1'b1;

    function [15:0] keep2len;
        input [DATA_WIDTH / 8 - 1:0] keep;
        reg [15:0] i; 
    begin
        keep2len = 0;
        for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
        begin
            if (keep[i])
            begin
                keep2len = i;
            end
        end
    end
    endfunction

    reg [63:0] nbytes;
    wire [63:0] current_nbytes = nbytes + keep2len(dp.keep);
    reg error;
    wire current_error = error | |dp.user;

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
//            state <= ST_;
            interface_state <= 0;
            nbytes <= 0;
            error <= 1'b0;
        end
        else if (dp.valid)
        begin
            if (dp.last)
            begin
                if (current_error)
                begin
                    interface_state.nerror <= interface_state.nerror + 1;
                end
                else
                begin
                    interface_state.nbytes <= interface_state.nbytes + current_nbytes;
                    interface_state.npackets <= interface_state.npackets + 1;
                end

                nbytes <= 0;
                error <= 1'b0;
            end
            else
            begin
                nbytes <= current_nbytes;
                error <= current_error;
            end
//            case (state)
//            default:
//            begin
//                state <= ST_;
//            end
//            endcase
        end
    end
endmodule