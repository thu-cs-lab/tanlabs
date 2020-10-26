`timescale 1ns / 1ps

module lfsr(
    input clk,
    input reset,

    output wire [63:0] o
);

    parameter TAP = 64'hd800000000000000;
    parameter INIT = 64'h2aa4a59850c62789;

    reg [63:0] state, next_state;
    reg feedback;

    integer i;
    always @ (*)
    begin
        next_state = state;
        for (i = 0; i < 64; i = i + 1)
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
        else
        begin
            state <= next_state;
        end
    end

    assign o = state;
endmodule
