`timescale 1ns / 1ps

module counter(
    input clk,
    input reset,

    input wire ce,

    input wire set,
    input wire [63:0] i,

    output wire [63:0] o
);

    parameter INIT = 64'd0;

    reg [63:0] state, next_state;
    reg feedback;

    integer j;
    always @ (*)
    begin
        next_state = set ? i : state;
        next_state = next_state + 1;
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
