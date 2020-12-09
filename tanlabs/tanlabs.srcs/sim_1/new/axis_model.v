`timescale 1ps / 1ps

// Read frames.txt, and send to 64-bit AXI-Stream.

module axis_model
#(
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH = 3
)
(
    input clk,
    input reset,

    output reg [DATA_WIDTH - 1:0] m_data,
    output reg [DATA_WIDTH / 8 - 1:0] m_keep,
    output reg m_last,
    output reg [DATA_WIDTH / 8 - 1:0] m_user,
    output reg [ID_WIDTH - 1:0] m_id,
    output reg m_valid,
    input m_ready
);

    integer fd;
    initial
    begin
        fd = $fopen("frames.txt", "r");
    end

    localparam ST_READ = 0;
    localparam ST_SEND_WAIT = 1;
    localparam ST_HALT = 2;

    integer state, ret, iface, len, i;

    initial
    begin
        state = ST_READ;
        m_valid = 0;
    end

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            state <= ST_READ;
            m_valid <= 0;
        end
        else
        begin
            case (state)
            ST_READ:
                if ($feof(fd))
                begin
                    $rewind(fd);
                    state <= ST_READ;
                end
                else
                begin
                    ret = $fscanf(fd, "%d%d", iface, len);
                    if (ret != 2)
                    begin
                        $rewind(fd);
                        state <= ST_READ;
                    end
                    else
                    begin
                        $write("Ingress frame from interface #%d, %d bytes\n", iface, len);
                        for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
                        begin
                            if (len > i)
                            begin
                                $fscanf(fd, "%x", m_data[i * 8 +: 8]);
                                m_keep[i] <= 1;
                            end
                            else
                            begin
                                m_keep[i] <= 0;
                            end
                        end
                        m_last <= (len <= DATA_WIDTH / 8) ? 1 : 0;
                        m_user <= 0;
                        m_id <= iface;
                        m_valid <= 1;
                        len = len - DATA_WIDTH / 8;
                        state <= ST_SEND_WAIT;
                    end
                end
            ST_SEND_WAIT:
                if (m_ready)
                begin
                    if (m_last)
                    begin
                        m_valid <= 0;
                        state <= ST_READ;
                    end
                    else
                    begin
                        for (i = 0; i < DATA_WIDTH / 8; i = i + 1)
                        begin
                            if (len > i)
                            begin
                                $fscanf(fd, "%x", m_data[i * 8 +: 8]);
                                m_keep[i] <= 1;
                            end
                            else
                            begin
                                m_keep[i] <= 0;
                            end
                        end
                        m_last <= (len <= DATA_WIDTH / 8) ? 1 : 0;
                        m_user <= 0;
                        m_id <= iface;
                        m_valid <= 1;
                        len = len - DATA_WIDTH / 8;
                        state <= ST_SEND_WAIT;
                    end
                end
            ST_HALT:
                state <= ST_HALT;
            default:
                state <= ST_READ;
            endcase
        end
    end
endmodule
