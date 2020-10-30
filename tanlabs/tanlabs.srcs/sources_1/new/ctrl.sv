`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ctrl
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input frame_data in,
    output wire in_ready,

    output frame_data out,
    input out_ready,

    // control signals
    input state_reg_t state_reg,
    output config_reg_t config_reg
);

    assign in_ready = 1'b1;
    assign out = 0;
    assign config_reg = 0;

endmodule