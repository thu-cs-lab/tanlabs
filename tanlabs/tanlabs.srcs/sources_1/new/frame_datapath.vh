`ifndef _TANLABS_SVH_
`define _TANLABS_SVH_

// 'w' means wide.
localparam DATAW_WIDTH = 8 * 48;
localparam ID_WIDTH = 3;

localparam VLAN_WIDTH = 8 * 4;

typedef struct packed
{
    logic [63:0] nbytes;
    logic [63:0] npackets;
    logic [63:0] nerror;
} interface_send_state_t;

typedef struct packed
{
    logic [63:0] nbytes;
    logic [63:0] npackets;
    logic [63:0] nerror;
} interface_recv_state_t;

typedef struct packed
{
    logic reset_counters;
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
localparam ETHERTYPE_VLAN = 16'h0081;

localparam ARP_MAGIC = 48'h040600080100;
localparam ARP_OPER_REQUEST = 16'h0100;
localparam ARP_OPER_REPLY = 16'h0200;

localparam PROTO_UDP = 8'd17;
localparam UDP_PAYLOAD_MAGIC = 48'h323232445754;  // TWD222

localparam MY_MAC = 48'h303032445754;  // TWD200
localparam MY_IP = 32'h6408080a;  // 10.8.8.100
localparam MY_PORT = 16'h60ea;  // 60000

`endif