`timescale 1ns / 1ps

module tb_mdio_ctrl(
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

    wire mdc, mdio_oe, mdi, mdo;
    wire mdio = mdio_oe ? mdo : 1'bz;
    wire eth_rstn;

    mdio_ctrl mdio_ctrl_i(
        .clk(clk_125M),
        .reset(reset),

        .mdc(mdc),
        .mdi(mdi),
        .mdo(mdo),
        .mdio_oe(mdio_oe),
        .eth_rstn(eth_rstn)
    );
endmodule
