`timescale 1ns / 1ps
`include "frame_datapath.vh"

module ctrl
#(
    parameter DATA_WIDTH,
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
    input state_reg_t state_reg,

    input [63:0] ticks
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

    reg [63:0] ticks_sample;
    state_reg_t state_reg_sample;

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

    reg [63:0] scratch;

    wire [63:0] regid_hton = {<<8{regid}};
    wire [63:0] regvalue_hton = {<<8{regvalue}};

    wire [REGID_IFACE_WIDTH - 1:0] ifaceid = regid[REGID_IFACE_SHIFT +: REGID_IFACE_WIDTH];
    config_reg_t confreg;
    interface_config_t config_sel;
    assign config_sel = confreg.conf[ifaceid];
    interface_send_state_t state_send_sel;
    assign state_send_sel = state_reg_sample.send[ifaceid];
    interface_recv_state_t state_recv_sel;
    assign state_recv_sel = state_reg_sample.recv[ifaceid];

    assign fifo_ready = state == ST_RECV || !fifo.valid;

    integer i;

    wire [127:0] var_ip_dst [0:3];
    reg [3:0] ip_dst_we;
    wire [63:0] ip_dst_data [0:3];

    always @ (*)
    begin
        for (i = 0; i < 4; i = i + 1)
        begin
            config_reg.conf[i] = confreg.conf[i];
            config_reg.conf[i].var_ip_dst = var_ip_dst[i];
        end
    end

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
            confreg <= 0;
            ticks_sample <= 0;
            state_reg_sample <= 0;

            ip_dst_we <= 0;
        end
        else
        begin
            for (i = 0; i < 4; i = i + 1)
            begin
                confreg.conf[i].set_ip_dst_ptr <= 1'b0;
            end
            ip_dst_we <= 0;

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
                                {regid, regvalue[63:16]} <= {<<8{fifo.data.payload.ip4.payload.udp.payload}};
                                regid[63] <= 1'b0;
                                checksum <=
                                    (32'(MY_IP[15:0]) + 32'(MY_IP[31:16]) + {16'd0, PROTO_UDP, 8'd0} + 32'h1800 + 32'h1800 + 32'(MY_PORT))
                                    + ((32'(fifo.data.payload.ip4.src[15:0]) + 32'(fifo.data.payload.ip4.src[31:16])) 
                                       + (32'(fifo.data.payload.ip4.payload.udp.src) + 32'(fifo.data.payload.ip4.payload.udp.checksum)))
                                    + ((32'(fifo.data.payload.ip4.payload.udp.payload[15:0]) + 32'(fifo.data.payload.ip4.payload.udp.payload[31:16]))
                                       + 32'(fifo.data.payload.ip4.payload.udp.payload[47:32]) + 32'(fifo.data.payload.ip4.payload.udp.payload[63:48])
                                       + 32'(fifo.data.payload.ip4.payload.udp.payload[79:64]) + 32'(fifo.data.payload.ip4.payload.udp.payload[95:80])
                                       + 32'(fifo.data.payload.ip4.payload.udp.payload[111:96]));
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
                                regvalue[15:0] <= {<<8{fifo.data[15:0]}};

                                checksum <= checksum + 32'(fifo.data[15:0]);

                                if (!fifo.keep[1])
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
                if (!regid[REGID_IP_DST_RAM_FLAG])
                begin
                    // Read / write registers.
                    if (!is_write)
                    begin
                        if (!regid[REGID_IFACE_FLAG])
                        begin
                            case (regid[0 +: REGID_REGID_WIDTH])
                            REGID_TICKS: regvalue <= ticks;
                            REGID_SCRATCH: regvalue <= scratch;
                            REGID_RESET_COUNTERS: regvalue <= confreg.conf[0].reset_counters;
                            REGID_TICKS_SAMPLE: regvalue <= ticks_sample;
                            default:
                            begin
                                // No such register.
                                regid <= REGID_INVALID;
                                regvalue <= 0;
                            end
                            endcase
                        end
                        else
                        begin
                            case (regid[0 +: REGID_REGID_WIDTH])
                            REGID_CONF_ENABLE: regvalue <= config_sel.enable;
                            REGID_CONF_MAC: regvalue <= {<<8{16'd0, config_sel.mac}};
                            REGID_CONF_MAC_DST: regvalue <= {<<8{16'd0, config_sel.mac_dst}};
                            REGID_CONF_IP_SRC_HI: regvalue <= {<<8{config_sel.ip_src[63:0]}};
                            REGID_CONF_IP_SRC_LO: regvalue <= {<<8{config_sel.ip_src[127:64]}};
                            REGID_CONF_IP_DST_HI: regvalue <= {<<8{config_sel.ip_dst[63:0]}};
                            REGID_CONF_IP_DST_LO: regvalue <= {<<8{config_sel.ip_dst[127:64]}};
                            REGID_CONF_PACKET_LEN: regvalue <= config_sel.packet_len;
                            REGID_CONF_GAP_LEN: regvalue <= config_sel.gap_len;
                            REGID_CONF_USE_VAR_IP_DST: regvalue <= config_sel.use_var_ip_dst;
                            REGID_CONF_USE_LFSR_IP_DST: regvalue <= config_sel.use_lfsr_ip_dst;
                            REGID_CONF_IP_DST_PTR_MASK: regvalue <= config_sel.ip_dst_ptr_mask;
                            REGID_IP_DST_PTR: regvalue <= state_send_sel.ip_dst_ptr;
                            REGID_SEND_NBYTES: regvalue <= state_send_sel.nbytes;
                            REGID_SEND_NPACKETS: regvalue <= state_send_sel.npackets;
                            REGID_RECV_NBYTES: regvalue <= state_recv_sel.nbytes;
                            REGID_RECV_NBYTES_L3: regvalue <= state_recv_sel.nbytes_l3;
                            REGID_RECV_NPACKETS: regvalue <= state_recv_sel.npackets;
                            REGID_RECV_NERROR: regvalue <= state_recv_sel.nerror;
                            REGID_RECV_LATENCY: regvalue <= state_recv_sel.latency;
                            default:
                            begin
                                // No such register.
                                regid <= REGID_INVALID;
                                regvalue <= 0;
                            end
                            endcase
                        end
                    end
                    else
                    begin
                        regvalue <= 0;
                        if (!regid[REGID_IFACE_FLAG])
                        begin
                            case (regid[0 +: REGID_REGID_WIDTH])
                            REGID_SCRATCH: scratch <= regvalue;
                            REGID_RESET_COUNTERS:
                            begin
                                confreg.conf[0].reset_counters <= regvalue[0];
                                confreg.conf[1].reset_counters <= regvalue[0];
                                confreg.conf[2].reset_counters <= regvalue[0];
                                confreg.conf[3].reset_counters <= regvalue[0];
                            end
                            REGID_SAMPLE:
                            begin
                                ticks_sample <= ticks;
                                state_reg_sample <= state_reg;
                            end
                            default:
                            begin
                                // No such writeable register.
                                regid <= REGID_INVALID;
                                regvalue <= 0;
                            end
                            endcase
                        end
                        else
                        begin
                            case (regid[0 +: REGID_REGID_WIDTH])
                            REGID_CONF_ENABLE: confreg.conf[ifaceid].enable <= regvalue;
                            REGID_CONF_MAC: confreg.conf[ifaceid].mac <= regvalue_hton;
                            REGID_CONF_MAC_DST: confreg.conf[ifaceid].mac_dst <= regvalue_hton;
                            REGID_CONF_IP_SRC_HI: confreg.conf[ifaceid].ip_src_hi <= regvalue_hton;
                            REGID_CONF_IP_SRC_LO: confreg.conf[ifaceid].ip_src <= {regvalue_hton, confreg.conf[ifaceid].ip_src_hi};
                            REGID_CONF_IP_DST_HI: confreg.conf[ifaceid].ip_dst_hi <= regvalue_hton;
                            REGID_CONF_IP_DST_LO: confreg.conf[ifaceid].ip_dst <= {regvalue_hton, confreg.conf[ifaceid].ip_dst_hi};
                            REGID_CONF_PACKET_LEN: confreg.conf[ifaceid].packet_len <= regvalue;
                            REGID_CONF_GAP_LEN: confreg.conf[ifaceid].gap_len <= regvalue;
                            REGID_CONF_USE_VAR_IP_DST: confreg.conf[ifaceid].use_var_ip_dst <= regvalue;
                            REGID_CONF_USE_LFSR_IP_DST: confreg.conf[ifaceid].use_lfsr_ip_dst <= regvalue;
                            REGID_CONF_IP_DST_PTR_MASK: confreg.conf[ifaceid].ip_dst_ptr_mask <= regvalue;
                            REGID_IP_DST_PTR:
                            begin
                                confreg.conf[ifaceid].set_ip_dst_ptr <= 1'b1;
                                confreg.conf[ifaceid].ip_dst_ptr <= regvalue;
                            end
                            default:
                            begin
                                // No such writeable register.
                                regid <= REGID_INVALID;
                                regvalue <= 0;
                            end
                            endcase
                        end
                    end
                end
                else
                begin
                    // Read / write IP dst RAM.
                    if (!regid[REGID_IFACE_FLAG])
                    begin
                        // No such register.
                        regid <= REGID_INVALID;
                        regvalue <= 0;
                    end
                    else
                    begin
                        if (!is_write)
                        begin
                            regvalue <= {<<8{ip_dst_data[ifaceid]}};
                        end
                        else
                        begin
                            ip_dst_we[ifaceid] <= 1'b1;
                        end
                    end
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
                out.keep <= {56{1'b1}};
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
                out.data.payload.ip4.payload.udp.payload <= {regvalue_hton[47:0], regid_hton};
                state <= ST_SEND_UDP;
            end
            ST_SEND_UDP:
            begin
                if (out_ready)
                begin
                    out.data <= regvalue_hton[63:48];
                    out.keep <= {54'd0, {2{1'b1}}};
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

    genvar j;
    generate
        for (j = 0; j < 4; j = j + 1)
        begin
            blk_mem_gen_ip_dst blk_mem_gen_ip_dst_i(
                .clka(eth_clk),
                .wea(1'b0),
                .addra(state_reg.send[j].ip_dst_ptr & confreg.conf[j].ip_dst_ptr_mask),
                .dina(128'd0),
                .douta(var_ip_dst[j]),

                .clkb(eth_clk),
                .web(ip_dst_we[j]),
                .addrb(regid[0 +: REGID_IP_DST_RAM_WIDTH]),
                .dinb(regvalue_hton),
                .doutb(ip_dst_data[j])
            );
        end
    endgenerate
endmodule