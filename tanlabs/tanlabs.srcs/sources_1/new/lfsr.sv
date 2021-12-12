`timescale 1ns / 1ps

module lfsr(
    input clk,
    input reset,

    input wire ce,

    input wire set,
    input wire [63:0] i,

    output wire [63:0] o
);

    parameter TAP = 64'hd800000000000000;
    parameter INIT = 64'h2aa4a59850c62789;

    reg [63:0] state, next_state;
    reg feedback;

    integer j;
    always @ (*)
    begin
        next_state = set ? i : state;
        for (j = 0; j < 64; j = j + 1)
        begin
            feedback = ^(next_state & TAP);
            next_state = {next_state[62:0], feedback};
        end
    end

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            state <= INIT;
        end
        else if (ce)
        begin
            state <= next_state;
        end
    end

    assign o = state;
endmodule
