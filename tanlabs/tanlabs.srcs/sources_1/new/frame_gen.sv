`timescale 1ns / 1ps
`include "frame_datapath.vh"

module frame_gen
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    output frame_data out,
    input out_ready,

    // control signals
    input interface_config_t interface_config,
    output interface_send_state_t interface_state
);

    assign out = 0;
    assign interface_state = 0;

endmodule