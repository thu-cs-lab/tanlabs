`timescale 1ns / 1ps

`include "frame_datapath.vh"

module frame_beat_width_converter
#(
    parameter IN_WIDTH = 8,
    parameter OUT_WIDTH = 64
)
(
    input wire clk,
    input wire rst,

    input frame_beat in,
    output reg in_ready,

    output frame_beat out,
    input wire out_ready
);

    generate
        if (IN_WIDTH <= OUT_WIDTH)
        begin : upsizer
            if (OUT_WIDTH % IN_WIDTH != 0)
            begin
                assertion_failure out_width_should_be_a_multiple_of_in_width();
            end

            localparam RATIO = OUT_WIDTH / IN_WIDTH;

            logic [RATIO - 1:0] state;
            integer i;

            always @ (*)
            begin
                in_ready = 1'b0;
                if (state[0])
                begin
                    if (out_ready || !out.valid)
                    begin
                        in_ready = 1'b1;
                    end
                end
                else
                begin
                    in_ready = 1'b1;
                end
            end

            always @ (posedge clk or posedge rst)
            begin
                if (rst)
                begin
                    out <= 0;
                    state <= 1;
                end
                else
                begin
                    if (out_ready)
                    begin
                        out.valid <= 1'b0;
                    end

                    if (in.valid && in_ready)
                    begin
                        if (state[0])
                        begin
                            out.is_first <= in.is_first;
                            out.meta <= in.meta;

                            out.keep <= 0;
                        end

                        for (i = 0; i < RATIO; i = i + 1)
                        begin
                            if (state[i])
                            begin
                                out.data[IN_WIDTH * i +: IN_WIDTH] <=
                                    in.data[IN_WIDTH - 1:0];
                                out.keep[IN_WIDTH / 8 * i +: IN_WIDTH / 8] <=
                                    in.keep[IN_WIDTH / 8 - 1:0];
                                out.user[IN_WIDTH / 8 * i +: IN_WIDTH / 8] <=
                                    in.user[IN_WIDTH / 8 - 1:0];
                            end
                        end

                        if (RATIO > 1)
                        begin
                            state <= {state[RATIO - 2:0], 1'b0};
                        end
                        if (state[RATIO - 1] || in.last)
                        begin
                            state <= 1;
                            out.valid <= 1'b1;
                        end
                        out.last <= in.last;
                    end
                end
            end
        end
        else
        begin : downsizer
            if (IN_WIDTH % OUT_WIDTH != 0)
            begin
                assertion_failure in_width_should_be_a_multiple_of_out_width();
            end

            localparam RATIO = IN_WIDTH / OUT_WIDTH;

            logic [RATIO - 1:0] state;

            assign in_ready = state[0] && (out_ready || !out.valid);

            logic in_last;

            always @ (posedge clk or posedge rst)
            begin
                if (rst)
                begin
                    out <= 0;
                    in_last <= 1'b0;
                    state <= 1;
                end
                else
                begin
                    if (state[0])
                    begin
                        if (out_ready || !out.valid)
                        begin
                            out.valid <= 1'b0;
                            if (in.valid)
                            begin
                                out.valid <= 1'b1;
                                out.is_first <= in.is_first;
                                out.meta <= in.meta;

                                out.data[IN_WIDTH - 1:0] <=
                                    in.data[IN_WIDTH - 1:0];
                                out.keep[IN_WIDTH / 8 - 1:0] <=
                                    in.keep[IN_WIDTH / 8 - 1:0];
                                out.user[IN_WIDTH / 8 - 1:0] <=
                                    in.user[IN_WIDTH / 8 - 1:0];

                                in_last <= in.last;

                                state <= {state[RATIO - 2:0], 1'b0};
                                out.last <= 1'b0;
                                if (state[RATIO - 1] || !in.keep[OUT_WIDTH / 8])
                                begin
                                    out.last <= in.last;
                                    state <= 1;
                                end
                            end
                        end
                    end
                    else
                    begin
                        if (out_ready)
                        begin
                            out.is_first <= 1'b0;
                            out.data[IN_WIDTH - 1:0] <=
                                {{OUT_WIDTH{1'b0}},
                                 out.data[IN_WIDTH - 1:OUT_WIDTH]};
                            out.keep[IN_WIDTH / 8 - 1:0] <=
                                {{(OUT_WIDTH / 8){1'b0}},
                                 out.keep[IN_WIDTH / 8 - 1:OUT_WIDTH / 8]};
                            out.user[IN_WIDTH / 8 - 1:0] <=
                                {{(OUT_WIDTH / 8){1'b0}},
                                 out.user[IN_WIDTH / 8 - 1:OUT_WIDTH / 8]};

                            state <= {state[RATIO - 2:0], 1'b0};
                            out.last <= 1'b0;
                            if (state[RATIO - 1] || !out.keep[OUT_WIDTH / 8 * 2])
                            begin
                                out.last <= in_last;
                                state <= 1;
                            end
                        end
                    end
                end
            end
        end
    endgenerate
endmodule
