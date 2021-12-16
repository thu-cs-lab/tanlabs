`timescale 1ns / 1ps

module reset_sync(
    input clk,
    input i,
    output wire o
);

    reg [31:0] reset_buff;
    always @ (posedge clk or posedge i)
    begin
        if (i)
        begin
            reset_buff <= 32'hffffffff;
        end
        else
        begin
            reset_buff <= {reset_buff[30:0], 1'b0};
        end
    end

    assign o = reset_buff[31];
endmodule
