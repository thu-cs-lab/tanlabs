`timescale 1ps / 1ps

module tb
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
);

    reg reset;
    initial begin
        reset = 1;
        #86000
        reset = 0;
    end

    wire clk_125M;

    clock clock_i(
        .clk_125M(clk_125M)
    );

    wire [DATA_WIDTH - 1:0] in_data;
    wire [DATA_WIDTH / 8 - 1:0] in_keep;
    wire in_last;
    wire [DATA_WIDTH / 8 - 1:0] in_user;
    wire [ID_WIDTH - 1:0] in_id;
    wire in_valid;
    wire in_ready;

    axis_model axis_model_i(
        .clk(clk_125M),
        .reset(reset),

        .m_data(in_data),
        .m_keep(in_keep),
        .m_last(in_last),
        .m_user(in_user),
        .m_id(in_id),
        .m_valid(in_valid),
        .m_ready(in_ready)
    );

    wire [DATA_WIDTH - 1:0] out_data;
    wire [DATA_WIDTH / 8 - 1:0] out_keep;
    wire out_last;
    wire [DATA_WIDTH / 8 - 1:0] out_user;
    wire [ID_WIDTH - 1:0] out_dest;
    wire out_valid;
    wire out_ready;

    wire [3:0] sfp_tb2dut_p;
    wire [3:0] sfp_tb2dut_n;
    wire [3:0] sfp_dut2tb_p = sfp_tb2dut_p;
    wire [3:0] sfp_dut2tb_n = sfp_tb2dut_n;

    sim_axis2sfp sim_axis2sfp_i(
        .reset(reset),
        .clk_125M(clk_125M),

        .s_data(in_data),
        .s_keep(in_keep),
        .s_last(in_last),
        .s_user(in_user),
        .s_dest(in_id),
        .s_valid(in_valid),
        .s_ready(in_ready),

        .m_data(out_data),
        .m_keep(out_keep),
        .m_last(out_last),
        .m_user(out_user),
        .m_id(out_dest),
        .m_valid(out_valid),
        .m_ready(out_ready),

        .sfp_rx_p(sfp_dut2tb_p),
        .sfp_rx_n(sfp_dut2tb_n),
        .sfp_tx_p(sfp_tb2dut_p),
        .sfp_tx_n(sfp_tb2dut_n)
    );

    axis_receiver axis_receiver_i(
        .clk(clk_125M),
        .reset(reset),

        .s_data(out_data),
        .s_keep(out_keep),
        .s_last(out_last),
        .s_user(out_user),
        .s_dest(out_dest),
        .s_valid(out_valid),
        .s_ready(out_ready)
    );
endmodule
