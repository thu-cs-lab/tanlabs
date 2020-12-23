`default_nettype none
`timescale 1ns / 1ps

module led_delayer(
    input wire clk,
    input wire reset,
    input wire [7:0] in_led,
    output wire [7:0] out_led
);

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1)
        begin
            reg [31:0] counter;
            always @ (posedge clk or posedge reset)
            begin
                if (reset)
                begin
                    counter <= 0;
                end
                else
                begin
                    if (in_led[i])
                    begin
                        counter <= 1250000;  // 10ms
                    end
                    else if (counter != 0)
                    begin
                        counter <= counter - 1;
                    end
                end
            end
            assign out_led[i] = counter != 0;
        end
    endgenerate
endmodule
