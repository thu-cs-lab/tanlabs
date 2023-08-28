`timescale 1ps / 1ps

// Read 64-bit AXI-Stream, and print.

module axis_receiver
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input wire clk,
    input wire reset,

    input wire [DATA_WIDTH - 1:0] s_data,
    input wire [DATA_WIDTH / 8 - 1:0] s_keep,
    input wire s_last,
    input wire [DATA_WIDTH / 8 - 1:0] s_user,
    input wire [ID_WIDTH - 1:0] s_dest,
    input wire s_valid,
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
    reg [ID_WIDTH - 1:0] dest;

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            dest <= 0;
        end
        else
        begin
            if (s_valid)
            begin
                if (is_first)
                begin
                    $write("Egress frame to interface #%d: ", s_dest);
                    $fwrite(fd, "%d ", s_dest);
                    dest <= s_dest;
                end
                else
                begin
                    if (s_dest != dest)
                    begin
                        $display("ASSERTION FAILED: AXI-Stream dest changes during one frame.");
                        $finish;
                    end
                end
                for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
                begin
                    if (s_keep[i])
                    begin
                        if (s_user[i])
                        begin
                            $display("ASSERTION FAILED: AXI-Stream user is high, BAD FRAME!");
                            $finish;
                        end
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
