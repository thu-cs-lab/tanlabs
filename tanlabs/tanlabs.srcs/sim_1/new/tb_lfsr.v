`timescale 1ps / 1ps

module tb_lfsr(
);
    reg reset, set;
    initial begin
        set = 0;
        reset = 1;
        #6000
        reset = 0;
        #60000
        set = 1;
        #6000
        set = 0;
    end

    wire clk_125M;

    clock clock_i(
        .clk_125M(clk_125M)
    );

    wire [63:0] o;
    lfsr lfsr_i(
        .clk(clk_125M),
        .reset(reset),

        .set(set),
        .i(64'd1),

        .o(o)
    );
endmodule
