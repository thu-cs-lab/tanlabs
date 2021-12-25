`ifndef _TANLABS_SVH_
`define _TANLABS_SVH_

// 'w' means wide.
localparam DATAW_WIDTH = 8 * 56;
localparam ID_WIDTH = 3;

localparam VLAN_WIDTH = 8 * 4;

typedef struct packed
{
    logic [63:0] nbytes;
    logic [63:0] npackets;
} interface_send_state_t;

typedef struct packed
{
    logic [63:0] nbytes;
    logic [63:0] nbytes_l3;
    logic [63:0] npackets;
    logic [63:0] nerror;
    logic [63:0] latency;
} interface_recv_state_t;

typedef struct packed
{
    logic enable;
    logic reset_counters;
    logic [47:0] mac;
    logic [47:0] mac_dst;
    logic [63:0] ip_src_hi;
    logic [127:0] ip_src;
    logic [63:0] ip_dst_hi;
    logic [127:0] ip_dst;
    logic [15:0] packet_len;
    logic [63:0] gap_len;
} interface_config_t;

typedef struct packed
{
    interface_send_state_t [3:0] send;
    interface_recv_state_t [3:0] recv;
} state_reg_t;

typedef struct packed
{
    interface_config_t [3:0] conf;
} config_reg_t;

typedef struct packed
{
    logic [15:0] id;
    logic [15:0] ethertype;
} vlan_tag_t;

typedef struct packed
{
    logic [(DATAW_WIDTH - 8 * 8 - 8 * 20 - 8 * 14) - 1:0] payload;
    logic [15:0] checksum;
    logic [15:0] len;
    logic [15:0] dst;
    logic [15:0] src;
} udp_hdr;

typedef struct packed
{
    logic [(DATAW_WIDTH - 8 * 40 - 8 * 14) - 1:0] payload;
    logic [127:0] dst;
    logic [127:0] src;
    logic [7:0] hop_limit;
    logic [7:0] next_hdr;
    logic [15:0] payload_len;
    logic [23:0] flow_lo;
    logic [3:0] version;
    logic [3:0] flow_hi;
} ip6_hdr;

typedef struct packed
{
    union packed
    {
        udp_hdr udp;
    } payload;
    logic [31:0] dst;
    logic [31:0] src;
    logic [15:0] checksum;
    logic [7:0] proto;
    logic [7:0] ttl;
    logic [15:0] flags;
    logic [15:0] id;
    logic [15:0] total_len;
    logic [7:0] dscp_ecn;
    logic [3:0] version;
    logic [3:0] ihl;
} ip4_hdr;

typedef struct packed
{
    logic [(DATAW_WIDTH - 8 * 28 - 8 * 14) - 1:0] payload;
    logic [31:0] tpa;
    logic [47:0] tha;
    logic [31:0] spa;
    logic [47:0] sha;
    logic [15:0] op;
    logic [47:0] magic;
} arp_hdr;

typedef struct packed
{
    union packed
    {
        ip6_hdr ip6;
        ip4_hdr ip4;
        arp_hdr arp;
    } payload;
    logic [15:0] ethertype;
    logic [47:0] src;
    logic [47:0] dst;
} ether_hdr;

typedef struct packed
{
    // AXI-Stream signals.
    ether_hdr data;
    logic [DATAW_WIDTH / 8 - 1:0] keep;
    logic last;
    logic [DATAW_WIDTH / 8 - 1:0] user;
    logic [ID_WIDTH - 1:0] id;  // The ingress interface.
    logic valid;

    // Control signals.
    logic is_first;  // Is this the first beat of a frame?

    // Other control signals.
    // **They are only effective at the first beat.**
    logic [ID_WIDTH - 1:0] dest;  // The egress interface.
    logic drop;  // Drop this frame (i.e., this beat and the following beats till the last)?
} frame_data;

localparam ETHERTYPE_ARP = 16'h0608;
localparam ETHERTYPE_IP4 = 16'h0008;
localparam ETHERTYPE_IP6 = 16'hdd86;
localparam ETHERTYPE_VLAN = 16'h0081;

localparam ARP_MAGIC = 48'h040600080100;
localparam ARP_OPER_REQUEST = 16'h0100;
localparam ARP_OPER_REPLY = 16'h0200;

localparam PROTO_UDP = 8'd17;
localparam PROTO_TEST = 8'hfe;  // RFC 3692
localparam UDP_PAYLOAD_MAGIC = 48'h323232445754;  // TWD222

localparam MY_MAC = 48'h303032445754;  // TWD200
localparam MY_IP = 32'h6408080a;  // 10.8.8.100
localparam MY_PORT = 16'h60ea;  // 60000

// Global registers.
localparam REGID_INVALID = 0;
localparam REGID_TICKS = 1;
localparam REGID_SCRATCH = 2;
localparam REGID_RESET_COUNTERS = 3;
localparam REGID_SAMPLE = 4;
localparam REGID_TICKS_SAMPLE = 5;
// Per-interface registers.
localparam REGID_IFACE_WIDTH = ID_WIDTH;
localparam REGID_IFACE_SHIFT = 8;
localparam REGID_IFACE_FLAG = REGID_IFACE_SHIFT + REGID_IFACE_WIDTH;
localparam REGID_CONF_ENABLE = 0;
localparam REGID_CONF_MAC = 1;
localparam REGID_CONF_MAC_DST = 2;
localparam REGID_CONF_IP_SRC_HI = 3;
localparam REGID_CONF_IP_SRC_LO = 4;
localparam REGID_CONF_IP_DST_HI = 5;
localparam REGID_CONF_IP_DST_LO = 6;
localparam REGID_CONF_PACKET_LEN = 7;
localparam REGID_CONF_GAP_LEN = 8;
localparam REGID_SEND_NBYTES = 9;
localparam REGID_SEND_NPACKETS = 10;
localparam REGID_RECV_NBYTES = 11;
localparam REGID_RECV_NBYTES_L3 = 12;
localparam REGID_RECV_NPACKETS = 13;
localparam REGID_RECV_NERROR = 14;
localparam REGID_RECV_LATENCY = 15;

function [DATAW_WIDTH - 1:0] expand_pattern;
    input [63:0] pattern;
    reg [63:0] pattern_reversed;
begin
    pattern_reversed = {<<1{pattern}};
    expand_pattern = {pattern_reversed ^ 64'h5555555555555555,
                      pattern_reversed ^ 64'hffffffffffffffff,
                      pattern_reversed,
                      pattern ^ 64'haaaaaaaaaaaaaaaa,
                      pattern ^ 64'h5555555555555555,
                      pattern ^ 64'hffffffffffffffff,
                      pattern};
end
endfunction

`endif