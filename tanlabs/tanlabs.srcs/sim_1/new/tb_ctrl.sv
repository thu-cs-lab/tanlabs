`timescale 1ps / 1ps
`include "frame_datapath.vh"

module tb_ctrl
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

    frame_data in;
    wire in_ready;

    frame_data out;
    wire out_ready;

    config_reg_t config_reg;
    state_reg_t state_reg;
    assign state_reg = 0;

    axis_model
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    axis_model_i(
        .clk(clk_125M),
        .reset(reset),

        .m_data(in.data),
        .m_keep(in.keep),
        .m_last(in.last),
        .m_user(in.user),
        .m_id(in.id),
        .m_valid(in.valid),
        .m_ready(in_ready)
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

    ctrl
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    dut(
        .eth_clk(clk_125M),
        .reset(reset),

        .in(in),
        .in_ready(in_ready),

        .out(out),
        .out_ready(out_ready),

        .config_reg(config_reg),
        .state_reg(state_reg),

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
