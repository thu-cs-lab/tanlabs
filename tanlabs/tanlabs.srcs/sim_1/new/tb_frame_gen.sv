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
        interface_config.ip_src = 128'h01000000000000000000970406aa0e2a;
        interface_config.ip_dst = 128'h01000000000000000100970406aa0e2a;
        interface_config.packet_len = 46 + 14;
        interface_config.gap_len = 8 + 4 + 12;  // preamble, FCS, inter-frame gap
    end

    wire [63:0] random;
    lfsr lfsr_i(
        .clk(clk_125M),
        .reset(reset),

        .o(random)
    );

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
    dut(
        .eth_clk(clk_125M),
        .reset(reset),

        .out(out),
        .out_ready(out_ready),

        .interface_config(interface_config),
        .interface_state(interface_state),

        .random(random),
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
