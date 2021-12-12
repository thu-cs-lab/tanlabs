`timescale 1ps / 1ps
`include "frame_datapath.vh"

module tb_frame_check
#(
    parameter DATA_WIDTH = 8 * 56,
    parameter ID_WIDTH = 3
)
(

);

    reg reset;
    initial begin
        reset = 1;
        #180000
        reset = 0;
    end

    wire clk_125M;

    clock clock_i(
        .clk_125M(clk_125M)
    );

    frame_data gen, out;
    wire gen_ready, out_ready;

    interface_config_t interface_send_config;
    interface_send_state_t interface_send_state;
    interface_config_t interface_recv_config;
    interface_recv_state_t interface_recv_state;

    always_comb
    begin
        interface_send_config = 0;
        interface_send_config.enable = 1'b1;
        interface_send_config.mac = MY_MAC;
        interface_send_config.mac_dst = MY_MAC + 2;
        interface_send_config.ip_src = 128'h01000000000000000000970406aa0e2a;
        interface_send_config.ip_dst = 128'h01000000000000000100970406aa0e2a;
        interface_send_config.packet_len = 46 + 14 + 108;
        interface_send_config.gap_len = 8 + 4 + 12;  // preamble, FCS, inter-frame gap

        interface_recv_config = 0;
        interface_recv_config.enable = 1'b1;
        interface_recv_config.mac = MY_MAC + 2;
    end

    reg [63:0] ticks;
    always @ (posedge clk_125M or posedge reset)
    begin
        if (reset)
        begin
            ticks <= 0;
        end
        else
        begin
            ticks <= ticks + 1;
        end
    end

    frame_gen
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_gen_i(
        .eth_clk(clk_125M),
        .reset(reset),

        .out(gen),
        .out_ready(gen_ready),

        .interface_config(interface_send_config),
        .interface_state(interface_send_state),

        .ticks(ticks)
    );

    wire [7:0] eth_data;
    wire eth_last, eth_user, eth_valid;

    egress_wrapper
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .ENABLE_FIFO(2'b01),
        .ENABLE_VLAN_TAGGER(0)
    )
    egress_wrapper_i(
        .eth_clk(clk_125M),
        .reset(reset),

        .in0(0),
        .in0_ready(),
        .in1(gen),
        .in1_ready(gen_ready),

        .m_data(eth_data),
        .m_last(eth_last),
        .m_user(eth_user),
        .m_valid(eth_valid),
        .m_ready(eth_ready)
    );

    reg eth_ready;
    always @ (posedge clk_125M or posedge reset)
    begin
        if (reset)
        begin
            eth_ready <= 1'b1;
        end
        else
        begin
            eth_ready <= 1'b1;
            if (eth_valid && eth_ready)
            begin
                if (eth_last)
                begin
                    eth_ready <= 1'b0;
                end
            end
        end
    end

    ingress_wrapper
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    dut(
        .eth_clk(clk_125M),
        .reset(reset),

        .s_data(eth_data),
        .s_last(eth_last),
        .s_user(eth_user),
        .s_valid(eth_valid & eth_ready),

        .out(out),
        .out_ready(out_ready),

        .interface_config(interface_recv_config),
        .interface_state(interface_recv_state),

        .ticks(ticks)
    );

    axis_receiver
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    axis_receiver_i(
        .clk(clk_125M),
        .reset(reset),

        .s_data(out.data),
        .s_keep(out.keep),
        .s_last(out.last),
        .s_user(out.user),
        .s_dest(out.dest),
        .s_valid(out.valid),
        .s_ready(out_ready)
    );
endmodule
