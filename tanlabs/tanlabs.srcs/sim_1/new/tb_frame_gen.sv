`timescale 1ps / 1ps
`include "frame_datapath.vh"

module tb_frame_gen
#(
    parameter DATA_WIDTH = 8 * 56,
    parameter ID_WIDTH = 3
)
(
    
);

    reg reset;
    initial begin
        reset = 1;
        #6000
        reset = 0;
    end

    wire clk_125M;

    clock clock_i(
        .clk_125M(clk_125M)
    );

    frame_data out;
    wire out_ready;

    interface_config_t interface_config;
    interface_send_state_t interface_state;

    always_comb
    begin
        interface_config = 0;
        interface_config.enable = 1'b1;
        interface_config.mac = MY_MAC;
        interface_config.mac_dst = MY_MAC + 2;
        interface_config.ip_src = MY_IP;
        interface_config.ip_dst = MY_IP + 2;
        interface_config.packet_len = 46 + 14;
        interface_config.gap_len = 0;
    end

    frame_gen dut(
        .eth_clk(clk_125M),
        .reset(reset),

        .out(out),
        .out_ready(out_ready),

        .interface_config(interface_config),
        .interface_state(interface_state)
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
