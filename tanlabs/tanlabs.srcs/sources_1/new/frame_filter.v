`timescale 1ns / 1ps

module frame_filter
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input eth_clk,
    input reset,

    input [DATA_WIDTH - 1:0] s_data,
    input [DATA_WIDTH / 8 - 1:0] s_keep,
    input s_last,
    input [DATA_WIDTH / 8 - 1:0] s_user,
    input [ID_WIDTH - 1:0] s_id,
    input s_valid,
    output wire s_ready,

    input drop,

    output wire [DATA_WIDTH - 1:0] m_data,
    output wire [DATA_WIDTH / 8 - 1:0] m_keep,
    output wire m_last,
    output wire [DATA_WIDTH / 8 - 1:0] m_user,
    output wire [ID_WIDTH - 1:0] m_id,
    output wire m_valid,
    input m_ready
);

    assign m_data = s_data;
    assign m_keep = s_keep;
    assign m_last = s_last;
    assign m_user = s_user;
    assign m_id = s_id;

    reg is_first;  // If previous is the last one, this is the first one.
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            is_first <= 1'b1;
        end
        else
        begin
            if (s_valid && s_ready)
            begin
                is_first <= s_last;
            end
        end
    end

    // If drop = 1 at the first beat, we drop this frame.
    reg drop_packet;
    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            drop_packet <= 1'b0;
        end
        else
        begin
            if (is_first && s_valid && s_ready)
            begin
                drop_packet <= drop;
            end
        end
    end

    wire drop_current = is_first ? drop : drop_packet;
    assign s_ready = m_ready || drop_current;
    assign m_valid = s_valid && !drop_current;
endmodule
