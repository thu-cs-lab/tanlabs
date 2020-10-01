`timescale 1ps / 1ps

// Read 64-bit AXI-Stream, and print.

module axis_receiver
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input clk,
    input reset,

    input [DATA_WIDTH - 1:0] s_data,
    input [DATA_WIDTH / 8 - 1:0] s_keep,
    input s_last,
    input [DATA_WIDTH / 8 - 1:0] s_user,
    input [ID_WIDTH - 1:0] s_dest,
    input s_valid,
    output wire s_ready
);

    assign s_ready = 1'b1;

    // Track frames and figure out when it is the first beat.
    reg is_first;
    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            is_first <= 1'b1;
        end
        else
        begin
            if (s_valid)
            begin
                is_first <= s_last;
            end
        end
    end

    integer fd;
    initial
    begin
        fd = $fopen("out_frames.txt", "w");
    end

    integer i;

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
        end
        else
        begin
            if (s_valid)
            begin
                if (is_first)
                begin
                    $write("Egress frame to interface #%d: ", s_dest);
                    $fwrite(fd, "%d ", s_dest);
                end
                for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
                begin
                    if (s_keep[i])
                    begin
                        $write("%02x ", s_data[i * 8 +: 8]);
                        $fwrite(fd, "%02x", s_data[i * 8 +: 8]);
                    end
                end
                if (s_last)
                begin
                    $write("\n");
                    $fwrite(fd, "\n");
                    $fflush(fd);
                end
            end
        end
    end
endmodule
