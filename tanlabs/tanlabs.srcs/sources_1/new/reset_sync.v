`timescale 1ns / 1ps

module reset_sync(
    input wire clk,
    input wire i,
    output wire o
);

    reg [7:0] reset_buff;
    always @ (posedge clk or posedge i)
    begin
        if (i)
        begin
            reset_buff <= 8'b11111111;
        end
        else
        begin
            reset_buff <= {reset_buff[6:0], 1'b0};
        end
    end

    assign o = reset_buff[7];
endmodule
