`timescale 1ps / 1ps

module tb_behav
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

    tanlabs 
    #(
        .SIM(1)
    )
    dut(
        .RST(reset),

        .gtrefclk_p(clk_125M),
        .gtrefclk_n(~clk_125M),

        .led(),

        .sfp_rx_los(4'd0),
        .sfp_rx_p(4'd0),
        .sfp_rx_n(4'd0),
        .sfp_tx_disable(),
        .sfp_tx_p(),
        .sfp_tx_n(),
        .sfp_led(),

        .sfp_sda(1'b0),
        .sfp_scl(1'b0)
    );
endmodule
