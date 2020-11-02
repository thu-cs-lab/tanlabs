`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ctrl
#(
    parameter DATA_WIDTH = 8 * 48,
    parameter ID_WIDTH = 3,
    parameter ID = 4
)
(
    input eth_clk,
    input reset,

    input frame_data in,
    output wire in_ready,

    output frame_data out,
    input out_ready,

    // control signals
    output config_reg_t config_reg,
    input state_reg_t state_reg
);

    frame_data filtered;
    wire filtered_ready;
    wire prog_full;

    assign in_ready = 1'b1;  // We drop frames when the FIFO is almost full, so we are always ready.

    frame_filter
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    )
    frame_filter_i(
        .eth_clk(eth_clk),
        .reset(reset),

        .s_data(in.data),
        .s_keep(in.keep),
        .s_last(in.last),
        .s_user(in.user),
        .s_id(in.id),
        .s_valid(in.valid),
        .s_ready(),

        .drop(prog_full),  // Drop this frame when the FIFO cannot hold a biggest frame.

        .m_data(filtered.data),
        .m_keep(filtered.keep),
        .m_last(filtered.last),
        .m_user(filtered.user),
        .m_id(filtered.id),
        .m_valid(filtered.valid),
        .m_ready(filtered_ready)
    );

    frame_data fifo;
    wire fifo_ready;

    axis_data_fifo_egress axis_data_fifo_egress_i(
        .s_axis_aresetn(~reset),
        .s_axis_aclk(eth_clk),
        .s_axis_tvalid(filtered.valid),
        .s_axis_tready(filtered_ready),
        .s_axis_tdata(filtered.data),
        .s_axis_tkeep(filtered.keep),
        .s_axis_tlast(filtered.last),
        .s_axis_tuser(filtered.user),
        .s_axis_tid(filtered.id),

        .m_axis_tvalid(fifo.valid),
        .m_axis_tready(fifo_ready),
        .m_axis_tdata(fifo.data),
        .m_axis_tkeep(fifo.keep),
        .m_axis_tlast(fifo.last),
        .m_axis_tuser(fifo.user),
        .m_axis_tid(fifo.id),

        .prog_full(prog_full)
    );

    assign fifo.dest = 0;

    function [15:0] checksum_reduce;
        input [31:0] sum;
        reg c;
        reg [15:0] sum16;
    begin
        {c, sum16} = 17'(sum[15:0]) + 17'(sum[31:16]);
        checksum_reduce = sum16 + 16'(c);
    end
    endfunction

    typedef enum
    {
        ST_RECV,
        ST_HANDLE,
        ST_HANDLE_ARP,
        ST_SEND_ARP,
        ST_HANDLE_UDP,
        ST_PREPARE_CHECKSUM,
        ST_PREPARE_UDP,
        ST_SEND_UDP,
        ST_SEND_UDP_2
    } state_t;
    state_t state;

    reg is_arp, is_udp, drop;
    reg [47:0] client_mac;
    reg [31:0] client_ip;
    reg [15:0] client_port;
    reg is_write;
    reg [63:0] regid;
    reg [63:0] regvalue;
    reg [31:0] checksum;
    reg [31:0] checksum_ip4;
    reg [15:0] counter;

    reg [63:0] ticks;

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            ticks <= 0;
        end
        else
        begin
            ticks <= ticks + 1;
        end
    end

    reg [63:0] scratch;

    wire [63:0] regid_hton = {<<8{regid}};
    wire [63:0] regvalue_hton = {<<8{regvalue}};

    assign fifo_ready = state == ST_RECV || !fifo.valid;

    always @ (posedge eth_clk or posedge reset)
    begin
        if (reset)
        begin
            state <= ST_RECV;
            is_arp <= 1'b0;
            is_udp <= 1'b0;
            drop <= 1'b0;
            client_mac <= 0;
            client_ip <= 0;
            client_port <= 0;
            is_write <= 1'b0;
            regid <= 0;
            regvalue <= 0;
            checksum <= 0;
            checksum_ip4 <= 0;
            counter <= 0;
            out <= 0;
            out.id <= ID;

            scratch <= 0;
            config_reg <= 0;
        end
        else
        begin
            case (state)
            ST_RECV:
            begin
                if (fifo.valid)
                begin
                    if (|(fifo.user & fifo.keep))
                    begin
                        drop <= 1'b1;
                    end
                    if (counter == 0)
                    begin
                        if (fifo.data.dst[0] == 1'b1 || fifo.data.dst == MY_MAC)
                        begin
                            client_mac <= fifo.data.src;
                            if (fifo.data.ethertype == ETHERTYPE_ARP
                                && fifo.data.payload.arp.magic == ARP_MAGIC
                                && fifo.data.payload.arp.op == ARP_OPER_REQUEST
                                && fifo.data.payload.arp.tpa == MY_IP)
                            begin
                                is_arp <= 1'b1;
                                client_ip <= fifo.data.payload.arp.spa;
                                if (!fifo.keep[41])
                                begin
                                    drop <= 1'b1;
                                end
                            end
                            else if (fifo.data.ethertype == ETHERTYPE_IP4
                                     && fifo.data.payload.ip4.version == 4'd4
                                     && fifo.data.payload.ip4.ihl == 4'd5
                                     && fifo.data.payload.ip4.total_len == 16'h2c00  // 20 + 8 + 16
                                     && fifo.data.payload.ip4.proto == PROTO_UDP
                                     && fifo.data.payload.ip4.dst == MY_IP
                                     && fifo.data.payload.ip4.payload.udp.dst == MY_PORT
                                     && fifo.data.payload.ip4.payload.udp.len == 16'h1800)
                            begin
                                is_arp <= 1'b0;
                                client_ip <= fifo.data.payload.ip4.src;
                                client_port <= fifo.data.payload.ip4.payload.udp.src;
                                is_write <= fifo.data.payload.ip4.payload.udp.payload[7];
                                regid[62:16] <= {<<8{fifo.data.payload.ip4.payload.udp.payload}};
                                checksum <=
                                    (32'(MY_IP[15:0]) + 32'(MY_IP[31:16]) + {16'd0, PROTO_UDP, 8'd0} + 32'h1800 + 32'h1800 + 32'(MY_PORT))
                                    + ((32'(fifo.data.payload.ip4.src[15:0]) + 32'(fifo.data.payload.ip4.src[31:16])) 
                                       + (32'(fifo.data.payload.ip4.payload.udp.src) + 32'(fifo.data.payload.ip4.payload.udp.checksum)))
                                    + ((32'(fifo.data.payload.ip4.payload.udp.payload[15:0]) + 32'(fifo.data.payload.ip4.payload.udp.payload[31:16]))
                                       + 32'(fifo.data.payload.ip4.payload.udp.payload[47:32]));
                                if (fifo.last)
                                begin
                                    drop <= 1'b1;
                                end
                            end
                            else
                            begin
                                drop <= 1'b1;
                            end
                        end
                        else
                        begin
                            drop <= 1'b1;
                        end
                    end
                    else if (counter == 1)
                    begin
                        if (!drop)
                        begin
                            if (!is_arp)
                            begin
                                regid[15:0] <= {<<8{fifo.data[15:0]}};
                                regvalue <= {<<8{fifo.data[16 +: 64]}};

                                checksum <= checksum + 32'(fifo.data[79:64])
                                    + ((32'(fifo.data[15:0]) + 32'(fifo.data[31:16]))
                                       + (32'(fifo.data[47:32]) + 32'(fifo.data[63:48])));

                                if (!fifo.keep[9])
                                begin
                                    drop <= 1'b1;
                                end
                            end
                        end
                    end
                    counter <= counter + 1;
                    if (fifo.last)
                    begin
                        counter <= 0;
                        state <= ST_HANDLE;
                    end
                end
            end
            ST_HANDLE:
            begin
                if (drop)
                begin
                    drop <= 1'b0;
                    state <= ST_RECV;
                end
                else if (is_arp)
                begin
                    state <= ST_HANDLE_ARP;
                end
                else
                begin
                    $display("checksum: %04x", checksum_reduce(checksum));
                    if (checksum_reduce(checksum) == 16'hffff)
                    begin
                        state <= ST_HANDLE_UDP;
                    end
                    else
                    begin
                        $display("drop UDP (checksum wrong)");
                        state <= ST_RECV;
                    end
                end
            end
            ST_HANDLE_ARP:
            begin
                $display("handle ARP");
                out <= 0;
                out.valid <= 1'b1;
                out.keep <= {6'd0, {42{1'b1}}};
                out.last <= 1'b1;
                out.data.ethertype <= ETHERTYPE_ARP;
                out.data.dst <= client_mac;
                out.data.src <= MY_MAC;
                out.data.payload.arp.magic <= ARP_MAGIC;
                out.data.payload.arp.op <= ARP_OPER_REPLY;
                out.data.payload.arp.spa <= MY_IP;
                out.data.payload.arp.sha <= MY_MAC;
                out.data.payload.arp.tpa <= client_ip;
                out.data.payload.arp.tha <= client_mac;
                state <= ST_SEND_ARP;
            end
            ST_SEND_ARP:
            begin
                if (out_ready)
                begin
                    out.valid <= 1'b0;
                    state <= ST_RECV;
                end
            end
            ST_HANDLE_UDP:
            begin
                $display("handle UDP");
                // TODO: read/write registers
                if (!is_write)
                begin
                    case (regid)
                    REGID_TICKS: regvalue <= ticks;
                    REGID_SCRATCH: regvalue <= scratch;
                    default:
                    begin
                        // no such register
                        regid <= REGID_INVALID;
                        regvalue <= 0;
                    end
                    endcase
                end
                else
                begin
                    case (regid)
                    REGID_SCRATCH: scratch <= regvalue;
                    default:
                    begin
                        // no such writeable register
                        regid <= REGID_INVALID;
                        regvalue <= 0;
                    end
                    endcase
                end
                state <= ST_PREPARE_CHECKSUM;
            end
            ST_PREPARE_CHECKSUM:
            begin
                checksum <=
                    ((32'(MY_IP[15:0]) + 32'(MY_IP[31:16]) + {16'd0, PROTO_UDP, 8'd0} + 32'h1800 + 32'h1800 + 32'(MY_PORT))
                     + 32'(client_port)
                     + (32'(client_ip[15:0]) + 32'(client_ip[31:16])))
                    + ((32'(regid_hton[15:0]) + 32'(regid_hton[31:16]))
                       + (32'(regid_hton[47:32]) + 32'(regid_hton[63:48])))
                    + ((32'(regvalue_hton[15:0]) + 32'(regvalue_hton[31:16]))
                       + (32'(regvalue_hton[47:32]) + 32'(regvalue_hton[63:48])));

                checksum_ip4 <=
                    32'h0045 + 32'h2c00 + {16'b0, 8'(PROTO_UDP), 8'd64} + 32'(MY_IP[15:0]) + 32'(MY_IP[31:16])
                    + (32'(client_ip[15:0]) + 32'(client_ip[31:16]));

                state <= ST_PREPARE_UDP;
            end
            ST_PREPARE_UDP:
            begin
                out <= 0;
                out.valid <= 1'b1;
                out.keep <= {48{1'b1}};
                out.last <= 1'b0;
                out.data.ethertype <= ETHERTYPE_IP4;
                out.data.dst <= client_mac;
                out.data.src <= MY_MAC;
                out.data.payload.ip4.version <= 4'd4;
                out.data.payload.ip4.ihl <= 4'd5;
                out.data.payload.ip4.total_len <= 16'h2c00;
                out.data.payload.ip4.ttl <= 8'd64;
                out.data.payload.ip4.proto <= PROTO_UDP;
                out.data.payload.ip4.checksum <= ~checksum_reduce(checksum_ip4);
                out.data.payload.ip4.src <= MY_IP;
                out.data.payload.ip4.dst <= client_ip;
                out.data.payload.ip4.payload.udp.src <= MY_PORT;
                out.data.payload.ip4.payload.udp.dst <= client_port;
                out.data.payload.ip4.payload.udp.len <= 16'h1800;
                out.data.payload.ip4.payload.udp.checksum <= ~checksum_reduce(checksum);
                out.data.payload.ip4.payload.udp.payload <= regid_hton[47:0];
                state <= ST_SEND_UDP;
            end
            ST_SEND_UDP:
            begin
                if (out_ready)
                begin
                    out.data <= {regvalue_hton, regid_hton[63:48]};
                    out.keep <= {38'd0, {10{1'b1}}};
                    out.last <= 1'b1;
                    state <= ST_SEND_UDP_2;
                end
            end
            ST_SEND_UDP_2:
            begin
                if (out_ready)
                begin
                    out.valid <= 1'b0;
                    state <= ST_RECV;
                end
            end
            default:
            begin
                state <= ST_RECV;
            end
            endcase
            out.id <= ID;
        end
    end
endmodule