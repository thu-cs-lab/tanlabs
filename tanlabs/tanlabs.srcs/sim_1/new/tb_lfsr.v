`timescale 1ps / 1ps

module tb_lfsr(
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

    wire [63:0] o;
    lfsr lfsr_i(
        .clk(clk_125M),
        .reset(reset),

        .o(o)
    );
endmodule
