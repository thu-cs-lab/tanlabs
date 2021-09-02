`ifndef _FRAME_DATAPATH_VH_
`define _FRAME_DATAPATH_VH_

// 'w' means wide.
localparam DATAW_WIDTH = 8 * 56;
localparam ID_WIDTH = 3;

// README: Your code here.

typedef struct packed
{
    logic [(DATAW_WIDTH - 8 * 40 - 8 * 14) - 1:0] p;
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
    ip6_hdr ip6;
    logic [15:0] ethertype;
    logic [47:0] src;
    logic [47:0] dst;
} ether_hdr;

typedef struct packed
{
    // Per-frame metadata.
    // **They are only effective at the first beat.**
    logic [ID_WIDTH - 1:0] id;  // The ingress interface.
    logic [ID_WIDTH - 1:0] dest;  // The egress interface.
    logic drop;  // Drop this frame (i.e., this beat and the following beats till the last)?
    logic dont_touch;  // Do not touch this beat!

    // Drop the next frame? It is useful when you need to shrink a frame
    // (e.g., replace an IPv4 packet to an ARP request).
    // You can do so by setting both last and drop_next.
    logic drop_next;

    // README: Your code here.
} frame_meta;

typedef struct packed
{
    // AXI-Stream signals.
    ether_hdr data;
    logic [DATAW_WIDTH / 8 - 1:0] keep;
    logic last;
    logic [DATAW_WIDTH / 8 - 1:0] user;
    logic valid;

    // Handy signals.
    logic is_first;  // Is this the first beat of a frame?

    frame_meta meta;
} frame_beat;

`define should_handle(b) \
(b.valid && b.is_first && !b.meta.drop && !b.meta.dont_touch)

// README: Your code here. You can define some other constants like EtherType.
localparam ID_CPU = 3'd4;  // The interface ID of CPU is 4.

localparam ETHERTYPE_IP6 = 16'hdd86;

`endif
